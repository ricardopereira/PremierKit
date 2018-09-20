//
//  Premier+URLError.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 20/09/2018.
//  Copyright © 2018 Ricardo Pereira. All rights reserved.
//

import Foundation

extension URLError.Code: CustomStringConvertible {

    public var description: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .cancelled:
            return "Cancelled"
        case .badURL:
            return "Bad URL"
        case .timedOut:
            return "Timed out"
        case .unsupportedURL:
            return "Unsupported URL"
        case .cannotFindHost:
            return "Cannot find host"
        case .cannotConnectToHost:
            return "Cannot connect to host"
        case .networkConnectionLost:
            return "Network connection lost"
        case .dnsLookupFailed:
            return "DNS lookup failed"
        case .httpTooManyRedirects:
            return "HTTP too many redirects"
        case .resourceUnavailable:
            return "Resource unavailable"
        case .notConnectedToInternet:
            return "No active internet connection"
        case .redirectToNonExistentLocation:
            return "Redirect to non existent location"
        case .badServerResponse:
            return "Bad server response"
        case .userCancelledAuthentication:
            return "User cancelled authentication"
        case .userAuthenticationRequired:
            return "User authentication required"
        case .zeroByteResource:
            return "Zero byte resource"
        case .cannotDecodeRawData:
            return "Cannot decode raw data"
        case .cannotDecodeContentData:
            return "Cannot decode content data"
        case .cannotParseResponse:
            return "Cannot parse response"
        case .appTransportSecurityRequiresSecureConnection:
            return "App transport security requires secure connection"
        case .fileDoesNotExist:
            return "File does not exist"
        case .fileIsDirectory:
            return "File is directory"
        case .noPermissionsToReadFile:
            return "No permissions to read file"
        case .dataLengthExceedsMaximum:
            return "Data length exceeds maximum"
        case .secureConnectionFailed:
            return "Secure connection failed"
        case .serverCertificateHasBadDate:
            return "Server certificate has bad date"
        case .serverCertificateUntrusted:
            return "Server certificate untrusted"
        case .serverCertificateHasUnknownRoot:
            return "Server certificate has unknown root"
        case .serverCertificateNotYetValid:
            return "Server certificate not yet valid"
        case .clientCertificateRejected:
            return "Client certificate rejected"
        case .clientCertificateRequired:
            return "Client certificate required"
        case .cannotLoadFromNetwork:
            return "Cannot load from network"
        case .cannotCreateFile:
            return "Cannot create file"
        case .cannotOpenFile:
            return "Cannot open file"
        case .cannotCloseFile:
            return "Cannot close file"
        case .cannotWriteToFile:
            return "Cannot write to file"
        case .cannotRemoveFile:
            return "Cannot remove file"
        case .cannotMoveFile:
            return "Cannot move file"
        case .downloadDecodingFailedMidStream:
            return "Download decoding failed mid stream"
        case .downloadDecodingFailedToComplete:
            return "Download decoding failed to complete"
        case .internationalRoamingOff:
            return "International roaming off"
        case .callIsActive:
            return "Call is active"
        case .dataNotAllowed:
            return "Data not allowed"
        case .requestBodyStreamExhausted:
            return "Request body stream exhausted"
        case .backgroundSessionRequiresSharedContainer:
            return "Background session requires shared container"
        case .backgroundSessionInUseByAnotherProcess:
            return "Background session in use by another process"
        case .backgroundSessionWasDisconnected:
            return "Background session was disconnected"
        default:
            return "Unknown"
        }
    }

}
