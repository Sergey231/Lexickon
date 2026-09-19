struct APIErrorDTO: Decodable, Sendable {
    let code: String?
    let message: String?
    let detail: Detail?

    var normalizedCode: String? {
        code ?? detail?.code ?? detail?.text
    }

    enum Detail: Decodable, Sendable {
        case text(String)
        case object(code: String?, message: String?)

        var code: String? {
            switch self {
            case .text:
                nil
            case let .object(code, _):
                code
            }
        }

        var text: String? {
            switch self {
            case let .text(value):
                value
            case let .object(_, message):
                message
            }
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let text = try? container.decode(String.self) {
                self = .text(text)
                return
            }
            let object = try container.decode(APIErrorDetailObjectDTO.self)
            self = .object(code: object.code, message: object.message)
        }
    }
}

private struct APIErrorDetailObjectDTO: Decodable {
    let code: String?
    let message: String?
}
