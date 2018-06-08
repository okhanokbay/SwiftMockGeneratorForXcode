import XCTest
import SourceKittenFramework
@testable import SwiftStructureInterface

class SwiftFileTests: XCTestCase {

    var file: FileImpl!

    override func setUp() {
        super.setUp()
        file = emptyFile
    }

    override func tearDown() {
        file = nil
        super.tearDown()
    }

    // MARK: - init

    func test_init_shouldSetItselfToAllChildren() {
        file = SKElementFactoryTestHelper.build(from: getNestedClassString())!
        assertFilesAreEquivalent(file.file, file)
        let classA = file.children[0]
        assertFilesAreEquivalent(classA.file, file)
        let classB = classA.children[0] as! TypeDeclarationImpl
        assertFilesAreEquivalent(classB.file, file)
        assertFilesAreEquivalent(classB.inheritedTypes[0].file, file)
        assertFilesAreEquivalent(classB.inheritedTypes[1].file, file)
        assertFilesAreEquivalent(classB.children[0].file, file)
        let methodA = classA.children[1] as! FunctionDeclarationImpl
        let methodAParam = methodA.parameters[0]
        assertFilesAreEquivalent(methodA.file, file)
        assertFilesAreEquivalent(methodAParam.file, file)
        assertFilesAreEquivalent(methodAParam.typeAnnotation.type.file, file)
        assertFilesAreEquivalent(methodA.returnType?.file, file)
    }

    func test_init_shouldSetItselfToAllChildrenWithNewParser() {
        file = ElementParser.parseFile(getProtocolString()) as! FileImpl
        assertFilesAreEquivalent(file.file, file)
        let protocolA = file.children[0] as! TypeDeclaration
        assertFilesAreEquivalent(protocolA.file, file)
        assertFilesAreEquivalent(protocolA.inheritedTypes[0].file, file)
        let initializer = protocolA.children[1] as! InitialiserDeclaration
        assertFilesAreEquivalent(initializer.file, file)
        assertFilesAreEquivalent(initializer.parameters[0].file, file)
        assertFilesAreEquivalent(initializer.parameters[0].typeAnnotation.file, file)
        assertFilesAreEquivalent(initializer.parameters[0].typeAnnotation.type.file, file)
        let property = protocolA.children[2] as! VariableDeclaration
        assertFilesAreEquivalent(property.file, file)
        assertFilesAreEquivalent(property.type.file, file)
        let method = protocolA.children[3] as! FunctionDeclaration
        let methodParam = method.parameters[0]
        assertFilesAreEquivalent(method.file, file)
        assertFilesAreEquivalent(method.genericParameterClause?.file, file)
        assertFilesAreEquivalent(method.genericParameterClause?.parameters[0].file, file)
        assertFilesAreEquivalent(methodParam.file, file)
        assertFilesAreEquivalent(methodParam.typeAnnotation.file, file)
        assertFilesAreEquivalent(methodParam.typeAnnotation.type.file, file)
        assertFilesAreEquivalent(method.returnType?.file, file)
    }

    func test_init_copyingFileToChildren_shouldDeliberatelyCauseRetainCycle() {
        weak var weakFile: Element?
        autoreleasepool {
            let file = SKElementFactoryTestHelper.build(from: getNestedClassString())
            weakFile = file
        }
        XCTAssertNotNil(weakFile)
    }
    
    func test_fileShouldBePresent_whenProgramHoldsAReferenceToAChild() {
        var child: Element?
        autoreleasepool {
            let file = SKElementFactoryTestHelper.build(from: getNestedClassString())!
            child = file.children[0]
        }
        XCTAssertNotNil(child?.file)
    }
    
    func test_copyOfFile_shouldKeepStrongReferencesToChildren() {
        var fileCopy: Element?
        autoreleasepool {
            let file = SKElementFactoryTestHelper.build(from: getNestedClassString())!
            fileCopy = file.children[0].file
        }
        XCTAssertEqual(fileCopy?.children.count, 1)
    }

    private func assertFilesAreEquivalent(_ lhs: Element?, _ rhs: Element?, line: UInt = #line) {
        XCTAssertNotNil(lhs, line: line)
        XCTAssertNotNil(rhs, line: line)
        guard let lhs = lhs, let rhs = rhs else { return }
        XCTAssertEqual(lhs.offset, rhs.offset, line: line)
        XCTAssertEqual(lhs.length, rhs.length, line: line)
        XCTAssertEqual(lhs.text, rhs.text, line: line)
        XCTAssertEqual(lhs.children.count, rhs.children.count, line: line)
        zip(lhs.children, rhs.children).forEach { XCTAssert($0 === $1, line: line) }
    }

    private func getNestedClassString() -> String {
        return """
class A {

    class B: C, D {

        func innerMethodA() {}
    }

    func methodA(a: A) -> T {}
}
"""
    }

    private func getProtocolString() -> String {
        return """
protocol A: B {
    init(i: Int)
    var a: A { get set }
    func b<T>(b: T) -> String
}
"""
    }
}
