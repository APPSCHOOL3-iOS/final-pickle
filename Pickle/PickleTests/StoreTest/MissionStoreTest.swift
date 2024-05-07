//
//  MissionStoreTest.swift
//  PickleTests
//
//  Created by 박형환 on 11/4/23.
//

import XCTest
@testable import Pickle

@MainActor
final class MissionStoreTest: XCTestCase {
    
    var sut: MissionStore!
    
    override func setUp() async throws {
        Self.setUpTodoDependency()
        sut = MissionStore()
    }
    
    override func tearDown() async throws {
        Container.removeCache()
        sut = nil
    }
    
    /// MissionStore 초기화 함수테스트
    func test_mission_init_test() throws {
        // Given
        var (times, behaviors): ([TimeMission], [BehaviorMission])
        
        // When
        (times, behaviors) = sut.fetch()
        
        // Then
        // MARK: Mission Store의 초기화 함수가 불려서 저장이 되지만
        // Realm을 인메모리 타입으로 하면 다시 초기화가 됨
        // XCTAssertEqual(times.count, 1)
        XCTAssertEqual(times.count, 0)
        // XCTAssertEqual(behaviors.count, 1)
        XCTAssertEqual(behaviors.count, 0)
    }
    
    /// 1. 미션이 없을경우 추가
    /// 2. 미션이 있을경우 추가 x
    func test_mission_add_fetch() throws {
        // Given
        ifNotExist_added()
        
        // When
        let (times, behaviors) = sut.fetch()
        
        // Then
        XCTAssertEqual(times.count, 1)
        XCTAssertEqual(behaviors.count, 1)
    }
    
    /// 미션을 정확하게 업데이트 할 수 있는지 비교
    func test_mission_update() throws {
        // Given
        ifNotExist_added()
        let (times, behaviors) = sut.fetch()
        XCTAssertEqual(times.count, 1)
        XCTAssertEqual(behaviors.count, 1)
        
        // When
        let newTime = try times.first!.update(path: \.status, to: MissionStatus.ongoing)
        let newBehavior = try behaviors.first!.update(path: \.status, to: MissionStatus.ongoing)
        
        sut.update(mission: .time(newTime))
        sut.update(mission: .behavior(newBehavior))
        
        // Then
        let (_times, _behaviors) = sut.fetch()
        
        XCTAssertEqual(_times.count, 1)
        XCTAssertEqual(_behaviors.count, 1)
        XCTAssertEqual(_times.first!.status, .ongoing)
        XCTAssertEqual(_behaviors.first!.status, .ongoing)
    }
    
    /// 미션 스토어 전체삭제 함수 테스트
    func test_deleteAllTest() throws {
        // Given
        ifNotExist_added()
        
        // When
        sut.deleteAll(mission: .time(.init()))
        sut.deleteAll(mission: .behavior(.init()))
        let missionsTuple = sut.fetch()
        
        // Then
        XCTAssertEqual(missionsTuple.0, [])
        XCTAssertEqual(missionsTuple.1, [])
    }
    
    /// 미션 스토어 삭제 함수 테스트
    func test_deleteTest() throws {
        // Given
        ifNotExist_added()
        
        // When
        let (time, behavior) = sut.fetch()
        sut.delete(mission: .time(time.first!))
        sut.delete(mission: .behavior(behavior.first!))
        let missionsTuple = sut.fetch()
        
        // Then
        XCTAssertEqual(missionsTuple.0, [])
        XCTAssertEqual(missionsTuple.1, [])
    }
    
    /// Observe하는 notification 테스트
    func test_mission_Notification_Token() throws {
        // Given
        ifNotExist_added()
        let (times, behaviors) = sut.fetch()
        
        // When
        sut.observe(mission: .time(times.first!))
        sut.observe(mission: .behavior(behaviors.first!))
        
        let newTime = try times.first!.update(path: \.status, to: MissionStatus.ongoing)
        let newBehavior: BehaviorMission = try behaviors.first!.update(path: \.status, to: MissionStatus.ongoing)
        
        sut.update(mission: .time(newTime))
        sut.update(mission: .behavior(newBehavior))
        
        let newBehavior2: BehaviorMission = try newBehavior.update(path: \.status, to: MissionStatus.complete)
        
        sut.update(mission: .behavior(newBehavior2))
        
        let expectation = XCTestExpectation(description: "combine Test")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            let newBehavior3: BehaviorMission
            = try! newBehavior2.update(path: \.date,
                                       to: Date())
            self?.sut.update(mission: .behavior(newBehavior3))
            expectation.fulfill()
        }
        
        wait(for: [expectation])
        
        // Then
        XCTAssertEqual(times.count, 1)
    }
}

extension MissionStoreTest {
    
    /// 미션이 존재하지 않으면 추가하는 함수
    private func ifNotExist_added() {
        let time = TimeMission(title: "기상 미션", status: .ready, date: Date(), wakeupTime: Date())
        let behavior = BehaviorMission(title: "걷기 미션", status: .ready, status1: .ready, status2: .ready, date: Date())
        let (t, b) = sut.fetch()
        
        if !t.isEmpty && !b.isEmpty { return }
        if t.isEmpty {
            sut.add(mission: .time(time))
        }
        if b.isEmpty {
            sut.add(mission: .behavior(behavior))
        }
    }
    
    static func setUpTodoDependency() {
        Container.register(DBStoreKey.self, RealmStore(type: .inmemory))
        Container.register(BehaviorRepoKey.self, BehaviorMissionRepository())
        Container.register(TimeRepoKey.self, TimeMissionRepository())
    }
}
