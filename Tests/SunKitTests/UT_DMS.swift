import XCTest
@testable import SunKit

final class UT_DMS: XCTestCase {
    
    
    /// Test of DMS init with decimal in input
    func testOfDMSDecimailInit(){
        
    //Test1: Convert −0.508333° to DMS format. The result shall be  -0°30''30'.
        
        //Step1: Initialize dmsUnderTest to −0.508333° and saving the expected output
        var dmsUnderTest: DMS = .init(decimal: -0.508333)
        
        //Step2: Check if the the values set is inside the correct range and isANegativeZero is TRUE
        XCTAssertTrue((dmsUnderTest.degrees == 0) && (dmsUnderTest.minutes == 30) && (29.99...30).contains(dmsUnderTest.seconds) && dmsUnderTest.isANegativeZero)
        
    //Test2: Convert 0.508333° to DMS format. The result shall be  0°30''30'.
        
        //Step3: Initialize dmsUnderTest to 0.508333° and saving the expected output
        dmsUnderTest = .init(decimal: 0.508333)
        
        //Step4: Check if the the values set is inside the correct range and isANegativeZero is FAlse
        XCTAssertTrue((dmsUnderTest.degrees == 0) && (dmsUnderTest.minutes == 30) && (29.99...30).contains(dmsUnderTest.seconds) && !dmsUnderTest.isANegativeZero)
        
    //Test3: Convert -300.3333° to DMS format. The result shall be  -300° 20′ 00′′.
       
        //Step5: Creating a DMS instance of  and saving the expected output
        dmsUnderTest = .init(decimal: -300.3333)
        
        //Step6: Call function under test and check that it returns a value close to expected output
        XCTAssertTrue((dmsUnderTest.degrees == -300) && (19...20).contains(dmsUnderTest.minutes) && (59...59.99).contains(dmsUnderTest.seconds) && !dmsUnderTest.isANegativeZero)
        
    }
    
    
    /// Test of dMS2Decimal
    func testOfdMS2Decimal(){
        
    //Test1: For 300° 20′ 00′′ his decimal number should be 300.3333
        //Step1: Creating a DMS instance of 300° 20′ 00′′ and saving the expected output
        var dmsUnderTest: DMS = .init(degrees: 300, minutes: 20, seconds: 00)
        var expectedOutput: Double = 300.3333
        
        //Step2: Call function under test and check that it returns a value close to expected output
        XCTAssertTrue(abs(dmsUnderTest.dMS2Decimal() - expectedOutput) < 0.01)

    //Test2: For -0°30''30' his decimal number should be -0.508333
        
        //Step3:  Creating a DMS instance of -0°30''30' and saving the expected output
        dmsUnderTest = .init(degrees: 0, minutes: 30, seconds: 30,isANegativeZero: true)
        expectedOutput = -0.508333
        
        //Step4: Call function under test and check that it returns a value close to expected output
        XCTAssertTrue(abs(dmsUnderTest.dMS2Decimal() - expectedOutput) < 0.01)
    }
}
