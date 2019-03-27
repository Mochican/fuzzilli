// Copyright 2019 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import XCTest
@testable import Fuzzilli

class VariableMapTests: XCTestCase {
    func v(_ n: Int) -> Variable {
        return Variable(number: n)
    }
    
    func testBasicVariableMapFeatures() {
        var m = VariableMap<Int>()
        
        XCTAssert(!m.contains(v(0)))
        
        m[v(42)] = 42
        XCTAssert(m.contains(v(42)) && m[v(42)] == 42)
        
        m[v(0)] = 0
        XCTAssert(m.contains(v(0)) && m[v(0)] == 0)
        XCTAssert(!m.contains(v(1)))
        m[v(1)] = 1
        XCTAssert(m.contains(v(1)) && m[v(1)] == 1)
        
        m.remove(v(1))
        XCTAssert(!m.contains(v(1)))
        XCTAssert(m.contains(v(0)) && m[v(0)] == 0)
    }
    
    func testVariableMapEquality() {
        var m1 = VariableMap<Bool>()
        XCTAssertEqual(m1, m1)
        
        var m2 = VariableMap<Bool>()
        XCTAssertEqual(m1, m2)

        for i in 0..<50 {
            let val = Bool.random()
            m1[v(i)] = val
            m2[v(i)] = val
        }
        XCTAssertEqual(m1, m2)
        
        m1.remove(v(2))
        XCTAssertNotEqual(m1, m2)
        m2.remove(v(2))
        XCTAssertEqual(m1, m2)
        
        // Add another fifty elements and compare with a new map built up in the opposite order.
        for i in 50..<100 {
            let val = Bool.random()
            m2[v(i)] = val
        }
        
        var m3 = VariableMap<Bool>()
        XCTAssertNotEqual(m1, m3)
        
        for i in (0..<100).reversed() {
            m3[v(i)] = m2[v(i)] ?? false
        }
        XCTAssertNotEqual(m1, m3)
        m3.remove(v(2))
        XCTAssertEqual(m3, m2)
        
        // Remove last 50 variables from m3, should now be equal to m1.
        for i in 50..<100 {
            m3.remove(v(i))
        }
        XCTAssertEqual(m3, m1)
    }
    
    func testVariableMapEncoding() {
        var map = VariableMap<Int>()
        
        for i in 0..<1000 {
            withProbability(0.75) {
                map[v(i)] = Int.random(in: 0..<1000000)
            }
        }
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let data = try! encoder.encode(map)
        let mapCopy = try! decoder.decode(VariableMap<Int>.self, from: data)
        
        XCTAssertEqual(map, mapCopy)
    }
    
    func testVariableMapHashing() {
        var map1 = VariableMap<Int>()
        var map2 = VariableMap<Int>()
        
        for i in 0..<1000 {
            withProbability(0.75) {
                let value = Int.random(in: 0..<1000000)
                map1[v(i)] = value
                map2[v(i)] = value
            }
        }
        
        XCTAssertEqual(map1, map2)
        XCTAssertEqual(map1.hashValue, map2.hashValue)
    }
}

extension VariableMapTests {
    static var allTests : [(String, (VariableMapTests) -> () throws -> Void)] {
        return [
            ("testBasicVariableMapFeatures", testBasicVariableMapFeatures),
            ("testVariableMapEquality", testVariableMapEquality),
            ("testVariableMapEncoding", testVariableMapEncoding),
            ("testVariableMapHashing", testVariableMapHashing)
        ]
    }
}