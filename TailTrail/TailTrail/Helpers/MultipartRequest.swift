import Foundation

struct MultipartRequest {
    
    public var boundary: String
    private var fields: [String: String] = [:]
    private var files: [(key: String, fileName: String, mimeType: String, fileData: Data)] = []
    
    public init(boundary: String = UUID().uuidString) {
        self.boundary = boundary
    }
    
    public mutating func add(key: String, value: String, data: Data) {
        fields[key] = value
    }
    
    public mutating func add(key: String, fileName: String, fileMimeType: String, fileData: Data) {
        files.append((key, fileName, fileMimeType, fileData))
    }
    
    public var httpContentType: String {
        "multipart/form-data; boundary=\(boundary)"
    }
    
    public var httpBody: Data {
        var data = Data()
        
        for (key, value) in fields {
            data.append("--\(boundary)\r\n")
            data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            data.append("\(value)\r\n")
        }
        
        for (key, fileName, mimeType, fileData) in files {
            data.append("--\(boundary)\r\n")
            data.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(fileName)\"\r\n")
            data.append("Content-Type: \(mimeType)\r\n\r\n")
            data.append(fileData)
            data.append("\r\n")
        }
        
        data.append("--\(boundary)--\r\n")
        return data
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
} 