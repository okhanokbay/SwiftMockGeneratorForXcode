import SourceKittenFramework

public class SKFormatRequest: FormatRequest {

    public init() {}

    public func format(filePath: String) throws -> String {
        return try SourceKittenFramework.File(path: filePath)!
            .format(trimmingTrailingWhitespace: false, useTabs: false, indentWidth: 4)
    }
}
