class FunctionDeclarationParser: BaseDeclarationParser<FunctionDeclaration> {

    override func parseDeclaration(builder: ParserBuilder) throws -> FunctionDeclaration {
        return try FunctionDeclarationImpl(children:builder
                .optional { try self.parseDeclarationIdentifier() }
                .optional { try self.parseGenericParameterClause() }
                .optional { try self.parseParameterClause() }
                .optional { try self.parseThrows() }
                .optional { try self.parseFunctionResult() }
                .optional { try self.parseWhereClause() }
                .optional { try self.parseCodeBlock() }
                .build())
    }
}
