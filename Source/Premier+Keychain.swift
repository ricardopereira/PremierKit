//
//  Premier+Keychain.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 26/09/2020.
//  Copyright © 2020 Ricardo Pereira. All rights reserved.
//

import Foundation

public class SecretKeychain {

    private let Class = String(kSecClass)
    private let AttributeAccount = String(kSecAttrAccount)
    private let AttributeAccessible = String(kSecAttrAccessible)
    private let AttributeService = String(kSecAttrService)
    private let MatchLimit = String(kSecMatchLimit)
    private let ReturnData = String(kSecReturnData)
    private let ValueData = String(kSecValueData)

    public let bundleIdentifier: String
    public let account: String
    public let accessible: Accessible

    public init(_ account: String, bundleIdentifier: String, accessible: Accessible = .whenUnlocked) {
        self.account = account
        self.bundleIdentifier = bundleIdentifier
        self.accessible = accessible
    }

    private func genericPasswordAttributes() -> [String : Any] {
        var attributes = [String: Any]()
        attributes[Class] = String(kSecClassGenericPassword)
        attributes[AttributeAccessible] = String(accessible.secAttrAccessibleValue)
        attributes[AttributeService] = bundleIdentifier
        attributes[AttributeAccount] = account
        return attributes
    }

    public func set(_ value: String) throws {
        guard let data = value.data(using: .utf8, allowLossyConversion: false) else {
            throw Status.conversionError
        }
        try set(data)
    }

    public func set(_ value: Data) throws {
        let query = genericPasswordAttributes()
        var status = SecItemCopyMatching(query as CFDictionary, nil)
        switch status {
        case errSecSuccess, errSecInteractionNotAllowed:
            var attributes = genericPasswordAttributes()
            attributes[ValueData] = value
            status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
            if status != errSecSuccess {
                throw securityError(status: status)
            }
        case errSecItemNotFound:
            var attributes = genericPasswordAttributes()
            attributes[ValueData] = value
            status = SecItemAdd(attributes as CFDictionary, nil)
            if status != errSecSuccess {
                throw securityError(status: status)
            }
        default:
            throw securityError(status: status)
        }
    }

    public func getData() throws -> Data? {
        var query = genericPasswordAttributes()
        query[MatchLimit] = kSecMatchLimitOne
        query[ReturnData] = kCFBooleanTrue
        query[AttributeAccount] = account

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data else {
                throw Status.unexpectedError
            }
            return data
        case errSecItemNotFound:
            return nil
        default:
            throw securityError(status: status)
        }
    }

    public func getString() throws -> String? {
        guard let data = try getData() else  {
            return nil
        }
        guard let string = String(data: data, encoding: .utf8) else {
            throw Status.conversionError
        }
        return string
    }

    @discardableResult
    public func removeValue() throws -> Bool {
        let query = genericPasswordAttributes()
        let status = SecItemDelete(query as CFDictionary)
        if status == errSecSuccess {
            return true
        }
        else if status == errSecItemNotFound {
            return false
        }
        else {
            throw securityError(status: status)
        }
    }

    public func containsValue() throws -> Bool {
        let query = genericPasswordAttributes()
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        switch status {
        case errSecSuccess:
            return true
        case errSecInteractionNotAllowed:
            throw securityError(status: errSecInteractionNotAllowed)
        case errSecItemNotFound:
            return false
        default:
            throw securityError(status: status)
        }
    }

    @discardableResult
    fileprivate class func securityError(status: OSStatus) -> Error {
        let error = Status(rawValue: status) ?? .unhandledError(code: status)
        if error != .userCanceled {
            print("OSStatus error:[\(error.errorCode)] \(error.description)")
        }
        return error
    }

    @discardableResult
    fileprivate func securityError(status: OSStatus) -> Error {
        return type(of: self).securityError(status: status)
    }

    // MARK: - kSecAttrAccessible

    public enum Accessible {
        case always
        case alwaysThisDeviceOnly
        case whenUnlocked
        case whenPasscodeSetThisDeviceOnly
        case whenUnlockedThisDeviceOnly
        case afterFirstUnlockThisDeviceOnly
        case afterFirstUnlock

        fileprivate var secAttrAccessibleValue: CFString {
            switch self {
            case .always:
                return kSecAttrAccessibleAlways
            case .alwaysThisDeviceOnly:
                return kSecAttrAccessibleAlwaysThisDeviceOnly
            case .whenUnlocked:
                return kSecAttrAccessibleWhenUnlocked
            case .whenPasscodeSetThisDeviceOnly:
                return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
            case .whenUnlockedThisDeviceOnly:
                return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            case .afterFirstUnlockThisDeviceOnly:
                return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            case .afterFirstUnlock:
                return kSecAttrAccessibleAfterFirstUnlock
            }
        }
    }

    // MARK: - OS Status

    public enum Status: RawRepresentable, Error, CustomNSError {
        case success
        case diskFull
        case io
        case opWr
        case param
        case wrPerm
        case allocate
        case userCanceled
        case badReq
        case notAvailable
        case readOnly
        case authFailed
        case noSuchKeychain
        case invalidKeychain
        case duplicateKeychain
        case duplicateCallback
        case invalidCallback
        case duplicateItem
        case itemNotFound
        case bufferTooSmall
        case dataTooLarge
        case noSuchAttr
        case invalidItemRef
        case invalidSearchRef
        case noSuchClass
        case noDefaultKeychain
        case interactionNotAllowed
        case readOnlyAttr
        case wrongSecVersion
        case keySizeNotAllowed
        case noStorageModule
        case noCertificateModule
        case noPolicyModule
        case interactionRequired
        case dataNotAvailable
        case dataNotModifiable
        case createChainFailed
        case invalidPrefsDomain
        case inDarkWake
        case aclNotSimple
        case policyNotFound
        case invalidTrustSetting
        case noAccessForItem
        case invalidOwnerEdit
        case trustNotAvailable
        case unsupportedFormat
        case unknownFormat
        case keyIsSensitive
        case multiplePrivKeys
        case passphraseRequired
        case invalidPasswordRef
        case invalidTrustSettings
        case noTrustSettings
        case pkcs12VerifyFailure
        case invalidCertificate
        case notSigner
        case decode
        case missingEntitlement
        case serviceNotAvailable
        case insufficientClientID
        case deviceReset
        case deviceFailed
        case appleAddAppACLSubject
        case applePublicKeyIncomplete
        case appleSignatureMismatch
        case appleInvalidKeyStartDate
        case appleInvalidKeyEndDate
        case conversionError
        case appleSSLv2Rollback
        case quotaExceeded
        case fileTooBig
        case invalidDatabaseBlob
        case invalidKeyBlob
        case incompatibleDatabaseBlob
        case incompatibleKeyBlob
        case hostNameMismatch
        case unknownCriticalExtensionFlag
        case noBasicConstraints
        case noBasicConstraintsCA
        case invalidAuthorityKeyID
        case invalidSubjectKeyID
        case invalidKeyUsageForPolicy
        case invalidExtendedKeyUsage
        case invalidIDLinkage
        case pathLengthConstraintExceeded
        case invalidRoot
        case crlExpired
        case crlNotValidYet
        case crlNotFound
        case crlServerDown
        case crlBadURI
        case unknownCertExtension
        case unknownCRLExtension
        case crlNotTrusted
        case crlPolicyFailed
        case idpFailure
        case smimeEmailAddressesNotFound
        case smimeBadExtendedKeyUsage
        case smimeBadKeyUsage
        case smimeKeyUsageNotCritical
        case smimeNoEmailAddress
        case smimeSubjAltNameNotCritical
        case sslBadExtendedKeyUsage
        case ocspBadResponse
        case ocspBadRequest
        case ocspUnavailable
        case ocspStatusUnrecognized
        case endOfData
        case incompleteCertRevocationCheck
        case networkFailure
        case ocspNotTrustedToAnchor
        case recordModified
        case ocspSignatureError
        case ocspNoSigner
        case ocspResponderMalformedReq
        case ocspResponderInternalError
        case ocspResponderTryLater
        case ocspResponderSignatureRequired
        case ocspResponderUnauthorized
        case ocspResponseNonceMismatch
        case codeSigningBadCertChainLength
        case codeSigningNoBasicConstraints
        case codeSigningBadPathLengthConstraint
        case codeSigningNoExtendedKeyUsage
        case codeSigningDevelopment
        case resourceSignBadCertChainLength
        case resourceSignBadExtKeyUsage
        case trustSettingDeny
        case invalidSubjectName
        case unknownQualifiedCertStatement
        case mobileMeRequestQueued
        case mobileMeRequestRedirected
        case mobileMeServerError
        case mobileMeServerNotAvailable
        case mobileMeServerAlreadyExists
        case mobileMeServerServiceErr
        case mobileMeRequestAlreadyPending
        case mobileMeNoRequestPending
        case mobileMeCSRVerifyFailure
        case mobileMeFailedConsistencyCheck
        case notInitialized
        case invalidHandleUsage
        case pvcReferentNotFound
        case functionIntegrityFail
        case internalError
        case memoryError
        case invalidData
        case mdsError
        case invalidPointer
        case selfCheckFailed
        case functionFailed
        case moduleManifestVerifyFailed
        case invalidGUID
        case invalidHandle
        case invalidDBList
        case invalidPassthroughID
        case invalidNetworkAddress
        case crlAlreadySigned
        case invalidNumberOfFields
        case verificationFailure
        case unknownTag
        case invalidSignature
        case invalidName
        case invalidCertificateRef
        case invalidCertificateGroup
        case tagNotFound
        case invalidQuery
        case invalidValue
        case callbackFailed
        case aclDeleteFailed
        case aclReplaceFailed
        case aclAddFailed
        case aclChangeFailed
        case invalidAccessCredentials
        case invalidRecord
        case invalidACL
        case invalidSampleValue
        case incompatibleVersion
        case privilegeNotGranted
        case invalidScope
        case pvcAlreadyConfigured
        case invalidPVC
        case emmLoadFailed
        case emmUnloadFailed
        case addinLoadFailed
        case invalidKeyRef
        case invalidKeyHierarchy
        case addinUnloadFailed
        case libraryReferenceNotFound
        case invalidAddinFunctionTable
        case invalidServiceMask
        case moduleNotLoaded
        case invalidSubServiceID
        case attributeNotInContext
        case moduleManagerInitializeFailed
        case moduleManagerNotFound
        case eventNotificationCallbackNotFound
        case inputLengthError
        case outputLengthError
        case privilegeNotSupported
        case deviceError
        case attachHandleBusy
        case notLoggedIn
        case algorithmMismatch
        case keyUsageIncorrect
        case keyBlobTypeIncorrect
        case keyHeaderInconsistent
        case unsupportedKeyFormat
        case unsupportedKeySize
        case invalidKeyUsageMask
        case unsupportedKeyUsageMask
        case invalidKeyAttributeMask
        case unsupportedKeyAttributeMask
        case invalidKeyLabel
        case unsupportedKeyLabel
        case invalidKeyFormat
        case unsupportedVectorOfBuffers
        case invalidInputVector
        case invalidOutputVector
        case invalidContext
        case invalidAlgorithm
        case invalidAttributeKey
        case missingAttributeKey
        case invalidAttributeInitVector
        case missingAttributeInitVector
        case invalidAttributeSalt
        case missingAttributeSalt
        case invalidAttributePadding
        case missingAttributePadding
        case invalidAttributeRandom
        case missingAttributeRandom
        case invalidAttributeSeed
        case missingAttributeSeed
        case invalidAttributePassphrase
        case missingAttributePassphrase
        case invalidAttributeKeyLength
        case missingAttributeKeyLength
        case invalidAttributeBlockSize
        case missingAttributeBlockSize
        case invalidAttributeOutputSize
        case missingAttributeOutputSize
        case invalidAttributeRounds
        case missingAttributeRounds
        case invalidAlgorithmParms
        case missingAlgorithmParms
        case invalidAttributeLabel
        case missingAttributeLabel
        case invalidAttributeKeyType
        case missingAttributeKeyType
        case invalidAttributeMode
        case missingAttributeMode
        case invalidAttributeEffectiveBits
        case missingAttributeEffectiveBits
        case invalidAttributeStartDate
        case missingAttributeStartDate
        case invalidAttributeEndDate
        case missingAttributeEndDate
        case invalidAttributeVersion
        case missingAttributeVersion
        case invalidAttributePrime
        case missingAttributePrime
        case invalidAttributeBase
        case missingAttributeBase
        case invalidAttributeSubprime
        case missingAttributeSubprime
        case invalidAttributeIterationCount
        case missingAttributeIterationCount
        case invalidAttributeDLDBHandle
        case missingAttributeDLDBHandle
        case invalidAttributeAccessCredentials
        case missingAttributeAccessCredentials
        case invalidAttributePublicKeyFormat
        case missingAttributePublicKeyFormat
        case invalidAttributePrivateKeyFormat
        case missingAttributePrivateKeyFormat
        case invalidAttributeSymmetricKeyFormat
        case missingAttributeSymmetricKeyFormat
        case invalidAttributeWrappedKeyFormat
        case missingAttributeWrappedKeyFormat
        case stagedOperationInProgress
        case stagedOperationNotStarted
        case verifyFailed
        case querySizeUnknown
        case blockSizeMismatch
        case publicKeyInconsistent
        case deviceVerifyFailed
        case invalidLoginName
        case alreadyLoggedIn
        case invalidDigestAlgorithm
        case invalidCRLGroup
        case certificateCannotOperate
        case certificateExpired
        case certificateNotValidYet
        case certificateRevoked
        case certificateSuspended
        case insufficientCredentials
        case invalidAction
        case invalidAuthority
        case verifyActionFailed
        case invalidCertAuthority
        case invaldCRLAuthority
        case invalidCRLEncoding
        case invalidCRLType
        case invalidCRL
        case invalidFormType
        case invalidID
        case invalidIdentifier
        case invalidIndex
        case invalidPolicyIdentifiers
        case invalidTimeString
        case invalidReason
        case invalidRequestInputs
        case invalidResponseVector
        case invalidStopOnPolicy
        case invalidTuple
        case multipleValuesUnsupported
        case notTrusted
        case noDefaultAuthority
        case rejectedForm
        case requestLost
        case requestRejected
        case unsupportedAddressType
        case unsupportedService
        case invalidTupleGroup
        case invalidBaseACLs
        case invalidTupleCredendtials
        case invalidEncoding
        case invalidValidityPeriod
        case invalidRequestor
        case requestDescriptor
        case invalidBundleInfo
        case invalidCRLIndex
        case noFieldValues
        case unsupportedFieldFormat
        case unsupportedIndexInfo
        case unsupportedLocality
        case unsupportedNumAttributes
        case unsupportedNumIndexes
        case unsupportedNumRecordTypes
        case fieldSpecifiedMultiple
        case incompatibleFieldFormat
        case invalidParsingModule
        case databaseLocked
        case datastoreIsOpen
        case missingValue
        case unsupportedQueryLimits
        case unsupportedNumSelectionPreds
        case unsupportedOperator
        case invalidDBLocation
        case invalidAccessRequest
        case invalidIndexInfo
        case invalidNewOwner
        case invalidModifyMode
        case missingRequiredExtension
        case extendedKeyUsageNotCritical
        case timestampMissing
        case timestampInvalid
        case timestampNotTrusted
        case timestampServiceNotAvailable
        case timestampBadAlg
        case timestampBadRequest
        case timestampBadDataFormat
        case timestampTimeNotAvailable
        case timestampUnacceptedPolicy
        case timestampUnacceptedExtension
        case timestampAddInfoNotAvailable
        case timestampSystemFailure
        case signingTimeMissing
        case timestampRejection
        case timestampWaiting
        case timestampRevocationWarning
        case timestampRevocationNotification
        case unexpectedError
        case unhandledError(code: OSStatus)

        public var rawValue: OSStatus {
            switch self {
            case .success:
                return errSecSuccess
            case .diskFull:
                return errSecDiskFull
            case .io:
                return errSecIO
            case .opWr:
                return errSecOpWr
            case .param:
                return errSecParam
            case .wrPerm:
                return errSecWrPerm
            case .allocate:
                return errSecAllocate
            case .userCanceled:
                return errSecUserCanceled
            case .badReq:
                return errSecBadReq
            case .notAvailable:
                return errSecNotAvailable
            case .readOnly:
                return errSecReadOnly
            case .authFailed:
                return errSecAuthFailed
            case .noSuchKeychain:
                return errSecNoSuchKeychain
            case .invalidKeychain:
                return errSecInvalidKeychain
            case .duplicateKeychain:
                return errSecDuplicateKeychain
            case .duplicateCallback:
                return errSecDuplicateCallback
            case .invalidCallback:
                return errSecInvalidCallback
            case .duplicateItem:
                return errSecDuplicateItem
            case .itemNotFound:
                return errSecItemNotFound
            case .bufferTooSmall:
                return errSecBufferTooSmall
            case .dataTooLarge:
                return errSecDataTooLarge
            case .noSuchAttr:
                return errSecNoSuchAttr
            case .invalidItemRef:
                return errSecInvalidItemRef
            case .invalidSearchRef:
                return errSecInvalidSearchRef
            case .noSuchClass:
                return errSecNoSuchClass
            case .noDefaultKeychain:
                return errSecNoDefaultKeychain
            case .interactionNotAllowed:
                return errSecInteractionNotAllowed
            case .readOnlyAttr:
                return errSecReadOnlyAttr
            case .wrongSecVersion:
                return errSecWrongSecVersion
            case .keySizeNotAllowed:
                return errSecKeySizeNotAllowed
            case .noStorageModule:
                return errSecNoStorageModule
            case .noCertificateModule:
                return errSecNoCertificateModule
            case .noPolicyModule:
                return errSecNoPolicyModule
            case .interactionRequired:
                return errSecInteractionRequired
            case .dataNotAvailable:
                return errSecDataNotAvailable
            case .dataNotModifiable:
                return errSecDataNotModifiable
            case .createChainFailed:
                return errSecCreateChainFailed
            case .invalidPrefsDomain:
                return errSecInvalidPrefsDomain
            case .inDarkWake:
                return errSecInDarkWake
            case .aclNotSimple:
                return errSecACLNotSimple
            case .policyNotFound:
                return errSecPolicyNotFound
            case .invalidTrustSetting:
                return errSecInvalidTrustSetting
            case .noAccessForItem:
                return errSecNoAccessForItem
            case .invalidOwnerEdit:
                return errSecInvalidOwnerEdit
            case .trustNotAvailable:
                return errSecTrustNotAvailable
            case .unsupportedFormat:
                return errSecUnsupportedFormat
            case .unknownFormat:
                return errSecUnknownFormat
            case .keyIsSensitive:
                return errSecKeyIsSensitive
            case .multiplePrivKeys:
                return errSecMultiplePrivKeys
            case .passphraseRequired:
                return errSecPassphraseRequired
            case .invalidPasswordRef:
                return errSecInvalidPasswordRef
            case .invalidTrustSettings:
                return errSecInvalidTrustSettings
            case .noTrustSettings:
                return errSecNoTrustSettings
            case .pkcs12VerifyFailure:
                return errSecPkcs12VerifyFailure
            case .invalidCertificate:
                return errSecInvalidCertificateRef
            case .notSigner:
                return errSecNotSigner
            case .decode:
                return errSecDecode
            case .missingEntitlement:
                return errSecMissingEntitlement
            case .serviceNotAvailable:
                return errSecServiceNotAvailable
            case .insufficientClientID:
                return errSecInsufficientClientID
            case .deviceReset:
                return errSecDeviceReset
            case .deviceFailed:
                return errSecDeviceFailed
            case .appleAddAppACLSubject:
                return errSecAppleAddAppACLSubject
            case .applePublicKeyIncomplete:
                return errSecApplePublicKeyIncomplete
            case .appleSignatureMismatch:
                return errSecAppleSignatureMismatch
            case .appleInvalidKeyStartDate:
                return errSecAppleInvalidKeyStartDate
            case .appleInvalidKeyEndDate:
                return errSecAppleInvalidKeyEndDate
            case .conversionError:
                return errSecConversionError
            case .appleSSLv2Rollback:
                return errSecAppleSSLv2Rollback
            case .quotaExceeded:
                return errSecQuotaExceeded
            case .fileTooBig:
                return errSecFileTooBig
            case .invalidDatabaseBlob:
                return errSecInvalidDatabaseBlob
            case .invalidKeyBlob:
                return errSecInvalidKeyBlob
            case .incompatibleDatabaseBlob:
                return errSecIncompatibleDatabaseBlob
            case .incompatibleKeyBlob:
                return errSecIncompatibleKeyBlob
            case .hostNameMismatch:
                return errSecHostNameMismatch
            case .unknownCriticalExtensionFlag:
                return errSecUnknownCriticalExtensionFlag
            case .noBasicConstraints:
                return errSecNoBasicConstraints
            case .noBasicConstraintsCA:
                return errSecNoBasicConstraintsCA
            case .invalidAuthorityKeyID:
                return errSecInvalidAuthorityKeyID
            case .invalidSubjectKeyID:
                return errSecInvalidSubjectKeyID
            case .invalidKeyUsageForPolicy:
                return errSecInvalidKeyUsageForPolicy
            case .invalidExtendedKeyUsage:
                return errSecInvalidExtendedKeyUsage
            case .invalidIDLinkage:
                return errSecInvalidIDLinkage
            case .pathLengthConstraintExceeded:
                return errSecPathLengthConstraintExceeded
            case .invalidRoot:
                return errSecInvalidRoot
            case .crlExpired:
                return errSecCRLExpired
            case .crlNotValidYet:
                return errSecCRLNotValidYet
            case .crlNotFound:
                return errSecCRLNotFound
            case .crlServerDown:
                return errSecCRLServerDown
            case .crlBadURI:
                return errSecCRLBadURI
            case .unknownCertExtension:
                return errSecUnknownCertExtension
            case .unknownCRLExtension:
                return errSecUnknownCRLExtension
            case .crlNotTrusted:
                return errSecCRLNotTrusted
            case .crlPolicyFailed:
                return errSecCRLPolicyFailed
            case .idpFailure:
                return errSecIDPFailure
            case .smimeEmailAddressesNotFound:
                return errSecSMIMEEmailAddressesNotFound
            case .smimeBadExtendedKeyUsage:
                return errSecSMIMEBadExtendedKeyUsage
            case .smimeBadKeyUsage:
                return errSecSMIMEBadKeyUsage
            case .smimeKeyUsageNotCritical:
                return errSecSMIMEKeyUsageNotCritical
            case .smimeNoEmailAddress:
                return errSecSMIMENoEmailAddress
            case .smimeSubjAltNameNotCritical:
                return errSecSMIMESubjAltNameNotCritical
            case .sslBadExtendedKeyUsage:
                return errSecSSLBadExtendedKeyUsage
            case .ocspBadResponse:
                return errSecOCSPBadResponse
            case .ocspBadRequest:
                return errSecOCSPBadRequest
            case .ocspUnavailable:
                return errSecOCSPUnavailable
            case .ocspStatusUnrecognized:
                return errSecOCSPStatusUnrecognized
            case .endOfData:
                return errSecEndOfData
            case .incompleteCertRevocationCheck:
                return errSecIncompleteCertRevocationCheck
            case .networkFailure:
                return errSecNetworkFailure
            case .ocspNotTrustedToAnchor:
                return errSecOCSPNotTrustedToAnchor
            case .recordModified:
                return errSecRecordModified
            case .ocspSignatureError:
                return errSecOCSPSignatureError
            case .ocspNoSigner:
                return errSecOCSPNoSigner
            case .ocspResponderMalformedReq:
                return errSecOCSPResponderMalformedReq
            case .ocspResponderInternalError:
                return errSecOCSPResponderInternalError
            case .ocspResponderTryLater:
                return errSecOCSPResponderTryLater
            case .ocspResponderSignatureRequired:
                return errSecOCSPResponderSignatureRequired
            case .ocspResponderUnauthorized:
                return errSecOCSPResponderUnauthorized
            case .ocspResponseNonceMismatch:
                return errSecOCSPResponseNonceMismatch
            case .codeSigningBadCertChainLength:
                return errSecCodeSigningBadCertChainLength
            case .codeSigningNoBasicConstraints:
                return errSecCodeSigningNoBasicConstraints
            case .codeSigningBadPathLengthConstraint:
                return errSecCodeSigningBadPathLengthConstraint
            case .codeSigningNoExtendedKeyUsage:
                return errSecCodeSigningNoExtendedKeyUsage
            case .codeSigningDevelopment:
                return errSecCodeSigningDevelopment
            case .resourceSignBadCertChainLength:
                return errSecResourceSignBadCertChainLength
            case .resourceSignBadExtKeyUsage:
                return errSecResourceSignBadExtKeyUsage
            case .trustSettingDeny:
                return errSecTrustSettingDeny
            case .invalidSubjectName:
                return errSecInvalidSubjectName
            case .unknownQualifiedCertStatement:
                return errSecUnknownQualifiedCertStatement
            case .mobileMeRequestQueued:
                return errSecMobileMeRequestQueued
            case .mobileMeRequestRedirected:
                return errSecMobileMeRequestRedirected
            case .mobileMeServerError:
                return errSecMobileMeServerError
            case .mobileMeServerNotAvailable:
                return errSecMobileMeServerNotAvailable
            case .mobileMeServerAlreadyExists:
                return errSecMobileMeServerAlreadyExists
            case .mobileMeServerServiceErr:
                return errSecMobileMeServerServiceErr
            case .mobileMeRequestAlreadyPending:
                return errSecMobileMeRequestAlreadyPending
            case .mobileMeNoRequestPending:
                return errSecMobileMeNoRequestPending
            case .mobileMeCSRVerifyFailure:
                return errSecMobileMeCSRVerifyFailure
            case .mobileMeFailedConsistencyCheck:
                return errSecMobileMeFailedConsistencyCheck
            case .notInitialized:
                return errSecNotInitialized
            case .invalidHandleUsage:
                return errSecInvalidHandleUsage
            case .pvcReferentNotFound:
                return errSecPVCReferentNotFound
            case .functionIntegrityFail:
                return errSecFunctionIntegrityFail
            case .internalError:
                return errSecInternalError
            case .memoryError:
                return errSecMemoryError
            case .invalidData:
                return errSecInvalidData
            case .mdsError:
                return errSecMDSError
            case .invalidPointer:
                return errSecInvalidPointer
            case .selfCheckFailed:
                return errSecSelfCheckFailed
            case .functionFailed:
                return errSecFunctionFailed
            case .moduleManifestVerifyFailed:
                return errSecModuleManifestVerifyFailed
            case .invalidGUID:
                return errSecInvalidGUID
            case .invalidHandle:
                return errSecInvalidHandle
            case .invalidDBList:
                return errSecInvalidDBList
            case .invalidPassthroughID:
                return errSecInvalidPassthroughID
            case .invalidNetworkAddress:
                return errSecInvalidNetworkAddress
            case .crlAlreadySigned:
                return errSecCRLAlreadySigned
            case .invalidNumberOfFields:
                return errSecInvalidNumberOfFields
            case .verificationFailure:
                return errSecVerificationFailure
            case .unknownTag:
                return errSecUnknownTag
            case .invalidSignature:
                return errSecInvalidSignature
            case .invalidName:
                return errSecInvalidName
            case .invalidCertificateRef:
                return errSecInvalidCertificateRef
            case .invalidCertificateGroup:
                return errSecInvalidCertificateGroup
            case .tagNotFound:
                return errSecTagNotFound
            case .invalidQuery:
                return errSecInvalidQuery
            case .invalidValue:
                return errSecInvalidValue
            case .callbackFailed:
                return errSecCallbackFailed
            case .aclDeleteFailed:
                return errSecACLDeleteFailed
            case .aclReplaceFailed:
                return errSecACLReplaceFailed
            case .aclAddFailed:
                return errSecACLAddFailed
            case .aclChangeFailed:
                return errSecACLChangeFailed
            case .invalidAccessCredentials:
                return errSecInvalidAccessCredentials
            case .invalidRecord:
                return errSecInvalidRecord
            case .invalidACL:
                return errSecInvalidACL
            case .invalidSampleValue:
                return errSecInvalidSampleValue
            case .incompatibleVersion:
                return errSecIncompatibleVersion
            case .privilegeNotGranted:
                return errSecPrivilegeNotGranted
            case .invalidScope:
                return errSecInvalidScope
            case .pvcAlreadyConfigured:
                return errSecPVCAlreadyConfigured
            case .invalidPVC:
                return errSecInvalidPVC
            case .emmLoadFailed:
                return errSecEMMLoadFailed
            case .emmUnloadFailed:
                return errSecEMMUnloadFailed
            case .addinLoadFailed:
                return errSecAddinLoadFailed
            case .invalidKeyRef:
                return errSecInvalidKeyRef
            case .invalidKeyHierarchy:
                return errSecInvalidKeyHierarchy
            case .addinUnloadFailed:
                return errSecAddinUnloadFailed
            case .libraryReferenceNotFound:
                return errSecLibraryReferenceNotFound
            case .invalidAddinFunctionTable:
                return errSecInvalidAddinFunctionTable
            case .invalidServiceMask:
                return errSecInvalidServiceMask
            case .moduleNotLoaded:
                return errSecModuleNotLoaded
            case .invalidSubServiceID:
                return errSecInvalidSubServiceID
            case .attributeNotInContext:
                return errSecAttributeNotInContext
            case .moduleManagerInitializeFailed:
                return errSecModuleManagerInitializeFailed
            case .moduleManagerNotFound:
                return errSecModuleManagerNotFound
            case .eventNotificationCallbackNotFound:
                return errSecEventNotificationCallbackNotFound
            case .inputLengthError:
                return errSecInputLengthError
            case .outputLengthError:
                return errSecOutputLengthError
            case .privilegeNotSupported:
                return errSecPrivilegeNotSupported
            case .deviceError:
                return errSecDeviceError
            case .attachHandleBusy:
                return errSecAttachHandleBusy
            case .notLoggedIn:
                return errSecNotLoggedIn
            case .algorithmMismatch:
                return errSecAlgorithmMismatch
            case .keyUsageIncorrect:
                return errSecKeyUsageIncorrect
            case .keyBlobTypeIncorrect:
                return errSecKeyBlobTypeIncorrect
            case .keyHeaderInconsistent:
                return errSecKeyHeaderInconsistent
            case .unsupportedKeyFormat:
                return errSecUnsupportedKeyFormat
            case .unsupportedKeySize:
                return errSecUnsupportedKeySize
            case .invalidKeyUsageMask:
                return errSecInvalidKeyUsageMask
            case .unsupportedKeyUsageMask:
                return errSecUnsupportedKeyUsageMask
            case .invalidKeyAttributeMask:
                return errSecInvalidKeyAttributeMask
            case .unsupportedKeyAttributeMask:
                return errSecUnsupportedKeyAttributeMask
            case .invalidKeyLabel:
                return errSecInvalidKeyLabel
            case .unsupportedKeyLabel:
                return errSecUnsupportedKeyLabel
            case .invalidKeyFormat:
                return errSecInvalidKeyFormat
            case .unsupportedVectorOfBuffers:
                return errSecUnsupportedVectorOfBuffers
            case .invalidInputVector:
                return errSecInvalidInputVector
            case .invalidOutputVector:
                return errSecInvalidOutputVector
            case .invalidContext:
                return errSecInvalidContext
            case .invalidAlgorithm:
                return errSecInvalidAlgorithm
            case .invalidAttributeKey:
                return errSecInvalidAttributeKey
            case .missingAttributeKey:
                return errSecMissingAttributeKey
            case .invalidAttributeInitVector:
                return errSecInvalidAttributeInitVector
            case .missingAttributeInitVector:
                return errSecMissingAttributeInitVector
            case .invalidAttributeSalt:
                return errSecInvalidAttributeSalt
            case .missingAttributeSalt:
                return errSecMissingAttributeSalt
            case .invalidAttributePadding:
                return errSecInvalidAttributePadding
            case .missingAttributePadding:
                return errSecMissingAttributePadding
            case .invalidAttributeRandom:
                return errSecInvalidAttributeRandom
            case .missingAttributeRandom:
                return errSecMissingAttributeRandom
            case .invalidAttributeSeed:
                return errSecInvalidAttributeSeed
            case .missingAttributeSeed:
                return errSecMissingAttributeSeed
            case .invalidAttributePassphrase:
                return errSecInvalidAttributePassphrase
            case .missingAttributePassphrase:
                return errSecMissingAttributePassphrase
            case .invalidAttributeKeyLength:
                return errSecInvalidAttributeKeyLength
            case .missingAttributeKeyLength:
                return errSecMissingAttributeKeyLength
            case .invalidAttributeBlockSize:
                return errSecInvalidAttributeBlockSize
            case .missingAttributeBlockSize:
                return errSecMissingAttributeBlockSize
            case .invalidAttributeOutputSize:
                return errSecInvalidAttributeOutputSize
            case .missingAttributeOutputSize:
                return errSecMissingAttributeOutputSize
            case .invalidAttributeRounds:
                return errSecInvalidAttributeRounds
            case .missingAttributeRounds:
                return errSecMissingAttributeRounds
            case .invalidAlgorithmParms:
                return errSecInvalidAlgorithmParms
            case .missingAlgorithmParms:
                return errSecMissingAlgorithmParms
            case .invalidAttributeLabel:
                return errSecInvalidAttributeLabel
            case .missingAttributeLabel:
                return errSecMissingAttributeLabel
            case .invalidAttributeKeyType:
                return errSecInvalidAttributeKeyType
            case .missingAttributeKeyType:
                return errSecMissingAttributeKeyType
            case .invalidAttributeMode:
                return errSecInvalidAttributeMode
            case .missingAttributeMode:
                return errSecMissingAttributeMode
            case .invalidAttributeEffectiveBits:
                return errSecInvalidAttributeEffectiveBits
            case .missingAttributeEffectiveBits:
                return errSecMissingAttributeEffectiveBits
            case .invalidAttributeStartDate:
                return errSecInvalidAttributeStartDate
            case .missingAttributeStartDate:
                return errSecMissingAttributeStartDate
            case .invalidAttributeEndDate:
                return errSecInvalidAttributeEndDate
            case .missingAttributeEndDate:
                return errSecMissingAttributeEndDate
            case .invalidAttributeVersion:
                return errSecInvalidAttributeVersion
            case .missingAttributeVersion:
                return errSecMissingAttributeVersion
            case .invalidAttributePrime:
                return errSecInvalidAttributePrime
            case .missingAttributePrime:
                return errSecMissingAttributePrime
            case .invalidAttributeBase:
                return errSecInvalidAttributeBase
            case .missingAttributeBase:
                return errSecMissingAttributeBase
            case .invalidAttributeSubprime:
                return errSecInvalidAttributeSubprime
            case .missingAttributeSubprime:
                return errSecMissingAttributeSubprime
            case .invalidAttributeIterationCount:
                return errSecInvalidAttributeIterationCount
            case .missingAttributeIterationCount:
                return errSecMissingAttributeIterationCount
            case .invalidAttributeDLDBHandle:
                return errSecInvalidAttributeDLDBHandle
            case .missingAttributeDLDBHandle:
                return errSecMissingAttributeDLDBHandle
            case .invalidAttributeAccessCredentials:
                return errSecInvalidAttributeAccessCredentials
            case .missingAttributeAccessCredentials:
                return errSecMissingAttributeAccessCredentials
            case .invalidAttributePublicKeyFormat:
                return errSecInvalidAttributePublicKeyFormat
            case .missingAttributePublicKeyFormat:
                return errSecMissingAttributePublicKeyFormat
            case .invalidAttributePrivateKeyFormat:
                return errSecInvalidAttributePrivateKeyFormat
            case .missingAttributePrivateKeyFormat:
                return errSecMissingAttributePrivateKeyFormat
            case .invalidAttributeSymmetricKeyFormat:
                return errSecInvalidAttributeSymmetricKeyFormat
            case .missingAttributeSymmetricKeyFormat:
                return errSecMissingAttributeSymmetricKeyFormat
            case .invalidAttributeWrappedKeyFormat:
                return errSecInvalidAttributeWrappedKeyFormat
            case .missingAttributeWrappedKeyFormat:
                return errSecMissingAttributeWrappedKeyFormat
            case .stagedOperationInProgress:
                return errSecStagedOperationInProgress
            case .stagedOperationNotStarted:
                return errSecStagedOperationNotStarted
            case .verifyFailed:
                return errSecVerifyFailed
            case .querySizeUnknown:
                return errSecQuerySizeUnknown
            case .blockSizeMismatch:
                return errSecBlockSizeMismatch
            case .publicKeyInconsistent:
                return errSecPublicKeyInconsistent
            case .deviceVerifyFailed:
                return errSecDeviceVerifyFailed
            case .invalidLoginName:
                return errSecInvalidLoginName
            case .alreadyLoggedIn:
                return errSecAlreadyLoggedIn
            case .invalidDigestAlgorithm:
                return errSecInvalidDigestAlgorithm
            case .invalidCRLGroup:
                return errSecInvalidCRLGroup
            case .certificateCannotOperate:
                return errSecCertificateCannotOperate
            case .certificateExpired:
                return errSecCertificateExpired
            case .certificateNotValidYet:
                return errSecCertificateNotValidYet
            case .certificateRevoked:
                return errSecCertificateRevoked
            case .certificateSuspended:
                return errSecCertificateSuspended
            case .insufficientCredentials:
                return errSecInsufficientCredentials
            case .invalidAction:
                return errSecInvalidAction
            case .invalidAuthority:
                return errSecInvalidAuthority
            case .verifyActionFailed:
                return errSecVerifyActionFailed
            case .invalidCertAuthority:
                return errSecInvalidCertAuthority
            case .invaldCRLAuthority:
                return errSecInvaldCRLAuthority
            case .invalidCRLEncoding:
                return errSecInvalidCRLEncoding
            case .invalidCRLType:
                return errSecInvalidCRLType
            case .invalidCRL:
                return errSecInvalidCRL
            case .invalidFormType:
                return errSecInvalidFormType
            case .invalidID:
                return errSecInvalidID
            case .invalidIdentifier:
                return errSecInvalidIdentifier
            case .invalidIndex:
                return errSecInvalidIndex
            case .invalidPolicyIdentifiers:
                return errSecInvalidPolicyIdentifiers
            case .invalidTimeString:
                return errSecInvalidTimeString
            case .invalidReason:
                return errSecInvalidReason
            case .invalidRequestInputs:
                return errSecInvalidRequestInputs
            case .invalidResponseVector:
                return errSecInvalidResponseVector
            case .invalidStopOnPolicy:
                return errSecInvalidStopOnPolicy
            case .invalidTuple:
                return errSecInvalidTuple
            case .multipleValuesUnsupported:
                return errSecMultipleValuesUnsupported
            case .notTrusted:
                return errSecNotTrusted
            case .noDefaultAuthority:
                return errSecNoDefaultAuthority
            case .rejectedForm:
                return errSecRejectedForm
            case .requestLost:
                return errSecRequestLost
            case .requestRejected:
                return errSecRequestRejected
            case .unsupportedAddressType:
                return errSecUnsupportedAddressType
            case .unsupportedService:
                return errSecUnsupportedService
            case .invalidTupleGroup:
                return errSecInvalidTupleGroup
            case .invalidBaseACLs:
                return errSecInvalidBaseACLs
            case .invalidTupleCredendtials:
                return errSecInvalidTupleCredendtials
            case .invalidEncoding:
                return errSecInvalidEncoding
            case .invalidValidityPeriod:
                return errSecInvalidValidityPeriod
            case .invalidRequestor:
                return errSecInvalidRequestor
            case .requestDescriptor:
                return errSecRequestDescriptor
            case .invalidBundleInfo:
                return errSecInvalidBundleInfo
            case .invalidCRLIndex:
                return errSecInvalidCRLIndex
            case .noFieldValues:
                return errSecNoFieldValues
            case .unsupportedFieldFormat:
                return errSecUnsupportedFieldFormat
            case .unsupportedIndexInfo:
                return errSecUnsupportedIndexInfo
            case .unsupportedLocality:
                return errSecUnsupportedLocality
            case .unsupportedNumAttributes:
                return errSecUnsupportedNumAttributes
            case .unsupportedNumIndexes:
                return errSecUnsupportedNumIndexes
            case .unsupportedNumRecordTypes:
                return errSecUnsupportedNumRecordTypes
            case .fieldSpecifiedMultiple:
                return errSecFieldSpecifiedMultiple
            case .incompatibleFieldFormat:
                return errSecIncompatibleFieldFormat
            case .invalidParsingModule:
                return errSecInvalidParsingModule
            case .databaseLocked:
                return errSecDatabaseLocked
            case .datastoreIsOpen:
                return errSecDatastoreIsOpen
            case .missingValue:
                return errSecMissingValue
            case .unsupportedQueryLimits:
                return errSecUnsupportedQueryLimits
            case .unsupportedNumSelectionPreds:
                return errSecUnsupportedNumSelectionPreds
            case .unsupportedOperator:
                return errSecUnsupportedOperator
            case .invalidDBLocation:
                return errSecInvalidDBLocation
            case .invalidAccessRequest:
                return errSecInvalidAccessRequest
            case .invalidIndexInfo:
                return errSecInvalidIndexInfo
            case .invalidNewOwner:
                return errSecInvalidNewOwner
            case .invalidModifyMode:
                return errSecInvalidModifyMode
            case .missingRequiredExtension:
                return errSecMissingRequiredExtension
            case .extendedKeyUsageNotCritical:
                return errSecExtendedKeyUsageNotCritical
            case .timestampMissing:
                return errSecTimestampMissing
            case .timestampInvalid:
                return errSecTimestampInvalid
            case .timestampNotTrusted:
                return errSecTimestampNotTrusted
            case .timestampServiceNotAvailable:
                return errSecTimestampServiceNotAvailable
            case .timestampBadAlg:
                return errSecTimestampBadAlg
            case .timestampBadRequest:
                return errSecTimestampBadRequest
            case .timestampBadDataFormat:
                return errSecTimestampBadDataFormat
            case .timestampTimeNotAvailable:
                return errSecTimestampTimeNotAvailable
            case .timestampUnacceptedPolicy:
                return errSecTimestampUnacceptedPolicy
            case .timestampUnacceptedExtension:
                return errSecTimestampUnacceptedExtension
            case .timestampAddInfoNotAvailable:
                return errSecTimestampAddInfoNotAvailable
            case .timestampSystemFailure:
                return errSecTimestampSystemFailure
            case .signingTimeMissing:
                return errSecSigningTimeMissing
            case .timestampRejection:
                return errSecTimestampRejection
            case .timestampWaiting:
                return errSecTimestampWaiting
            case .timestampRevocationWarning:
                return errSecTimestampRevocationWarning
            case .timestampRevocationNotification:
                return errSecTimestampRevocationNotification
            case .unexpectedError:
                return -99999
            case .unhandledError(let code):
                return code
            }
        }

        public init?(rawValue: OSStatus) {
            switch rawValue {
            case errSecSuccess:
                self = .success
            case errSecDiskFull:
                self = .diskFull
            case errSecIO:
                self = .io
            case errSecOpWr:
                self = .opWr
            case errSecParam:
                self = .param
            case errSecWrPerm:
                self = .wrPerm
            case errSecAllocate:
                self = .allocate
            case errSecUserCanceled:
                self = .userCanceled
            case errSecBadReq:
                self = .badReq
            case errSecNotAvailable:
                self = .notAvailable
            case errSecReadOnly:
                self = .readOnly
            case errSecAuthFailed:
                self = .authFailed
            case errSecNoSuchKeychain:
                self = .noSuchKeychain
            case errSecInvalidKeychain:
                self = .invalidKeychain
            case errSecDuplicateKeychain:
                self = .duplicateKeychain
            case errSecDuplicateCallback:
                self = .duplicateCallback
            case errSecInvalidCallback:
                self = .invalidCallback
            case errSecDuplicateItem:
                self = .duplicateItem
            case errSecItemNotFound:
                self = .itemNotFound
            case errSecBufferTooSmall:
                self = .bufferTooSmall
            case errSecDataTooLarge:
                self = .dataTooLarge
            case errSecNoSuchAttr:
                self = .noSuchAttr
            case errSecInvalidItemRef:
                self = .invalidItemRef
            case errSecInvalidSearchRef:
                self = .invalidSearchRef
            case errSecNoSuchClass:
                self = .noSuchClass
            case errSecNoDefaultKeychain:
                self = .noDefaultKeychain
            case errSecInteractionNotAllowed:
                self = .interactionNotAllowed
            case errSecReadOnlyAttr:
                self = .readOnlyAttr
            case errSecWrongSecVersion:
                self = .wrongSecVersion
            case errSecKeySizeNotAllowed:
                self = .keySizeNotAllowed
            case errSecNoStorageModule:
                self = .noStorageModule
            case errSecNoCertificateModule:
                self = .noCertificateModule
            case errSecNoPolicyModule:
                self = .noPolicyModule
            case errSecInteractionRequired:
                self = .interactionRequired
            case errSecDataNotAvailable:
                self = .dataNotAvailable
            case errSecDataNotModifiable:
                self = .dataNotModifiable
            case errSecCreateChainFailed:
                self = .createChainFailed
            case errSecInvalidPrefsDomain:
                self = .invalidPrefsDomain
            case errSecInDarkWake:
                self = .inDarkWake
            case errSecACLNotSimple:
                self = .aclNotSimple
            case errSecPolicyNotFound:
                self = .policyNotFound
            case errSecInvalidTrustSetting:
                self = .invalidTrustSetting
            case errSecNoAccessForItem:
                self = .noAccessForItem
            case errSecInvalidOwnerEdit:
                self = .invalidOwnerEdit
            case errSecTrustNotAvailable:
                self = .trustNotAvailable
            case errSecUnsupportedFormat:
                self = .unsupportedFormat
            case errSecUnknownFormat:
                self = .unknownFormat
            case errSecKeyIsSensitive:
                self = .keyIsSensitive
            case errSecMultiplePrivKeys:
                self = .multiplePrivKeys
            case errSecPassphraseRequired:
                self = .passphraseRequired
            case errSecInvalidPasswordRef:
                self = .invalidPasswordRef
            case errSecInvalidTrustSettings:
                self = .invalidTrustSettings
            case errSecNoTrustSettings:
                self = .noTrustSettings
            case errSecPkcs12VerifyFailure:
                self = .pkcs12VerifyFailure
            case errSecInvalidCertificateRef:
                self = .invalidCertificate
            case errSecNotSigner:
                self = .notSigner
            case errSecDecode:
                self = .decode
            case errSecMissingEntitlement:
                self = .missingEntitlement
            case errSecServiceNotAvailable:
                self = .serviceNotAvailable
            case errSecInsufficientClientID:
                self = .insufficientClientID
            case errSecDeviceReset:
                self = .deviceReset
            case errSecDeviceFailed:
                self = .deviceFailed
            case errSecAppleAddAppACLSubject:
                self = .appleAddAppACLSubject
            case errSecApplePublicKeyIncomplete:
                self = .applePublicKeyIncomplete
            case errSecAppleSignatureMismatch:
                self = .appleSignatureMismatch
            case errSecAppleInvalidKeyStartDate:
                self = .appleInvalidKeyStartDate
            case errSecAppleInvalidKeyEndDate:
                self = .appleInvalidKeyEndDate
            case errSecConversionError:
                self = .conversionError
            case errSecAppleSSLv2Rollback:
                self = .appleSSLv2Rollback
            case errSecQuotaExceeded:
                self = .quotaExceeded
            case errSecFileTooBig:
                self = .fileTooBig
            case errSecInvalidDatabaseBlob:
                self = .invalidDatabaseBlob
            case errSecInvalidKeyBlob:
                self = .invalidKeyBlob
            case errSecIncompatibleDatabaseBlob:
                self = .incompatibleDatabaseBlob
            case errSecIncompatibleKeyBlob:
                self = .incompatibleKeyBlob
            case errSecHostNameMismatch:
                self = .hostNameMismatch
            case errSecUnknownCriticalExtensionFlag:
                self = .unknownCriticalExtensionFlag
            case errSecNoBasicConstraints:
                self = .noBasicConstraints
            case errSecNoBasicConstraintsCA:
                self = .noBasicConstraintsCA
            case errSecInvalidAuthorityKeyID:
                self = .invalidAuthorityKeyID
            case errSecInvalidSubjectKeyID:
                self = .invalidSubjectKeyID
            case errSecInvalidKeyUsageForPolicy:
                self = .invalidKeyUsageForPolicy
            case errSecInvalidExtendedKeyUsage:
                self = .invalidExtendedKeyUsage
            case errSecInvalidIDLinkage:
                self = .invalidIDLinkage
            case errSecPathLengthConstraintExceeded:
                self = .pathLengthConstraintExceeded
            case errSecInvalidRoot:
                self = .invalidRoot
            case errSecCRLExpired:
                self = .crlExpired
            case errSecCRLNotValidYet:
                self = .crlNotValidYet
            case errSecCRLNotFound:
                self = .crlNotFound
            case errSecCRLServerDown:
                self = .crlServerDown
            case errSecCRLBadURI:
                self = .crlBadURI
            case errSecUnknownCertExtension:
                self = .unknownCertExtension
            case errSecUnknownCRLExtension:
                self = .unknownCRLExtension
            case errSecCRLNotTrusted:
                self = .crlNotTrusted
            case errSecCRLPolicyFailed:
                self = .crlPolicyFailed
            case errSecIDPFailure:
                self = .idpFailure
            case errSecSMIMEEmailAddressesNotFound:
                self = .smimeEmailAddressesNotFound
            case errSecSMIMEBadExtendedKeyUsage:
                self = .smimeBadExtendedKeyUsage
            case errSecSMIMEBadKeyUsage:
                self = .smimeBadKeyUsage
            case errSecSMIMEKeyUsageNotCritical:
                self = .smimeKeyUsageNotCritical
            case errSecSMIMENoEmailAddress:
                self = .smimeNoEmailAddress
            case errSecSMIMESubjAltNameNotCritical:
                self = .smimeSubjAltNameNotCritical
            case errSecSSLBadExtendedKeyUsage:
                self = .sslBadExtendedKeyUsage
            case errSecOCSPBadResponse:
                self = .ocspBadResponse
            case errSecOCSPBadRequest:
                self = .ocspBadRequest
            case errSecOCSPUnavailable:
                self = .ocspUnavailable
            case errSecOCSPStatusUnrecognized:
                self = .ocspStatusUnrecognized
            case errSecEndOfData:
                self = .endOfData
            case errSecIncompleteCertRevocationCheck:
                self = .incompleteCertRevocationCheck
            case errSecNetworkFailure:
                self = .networkFailure
            case errSecOCSPNotTrustedToAnchor:
                self = .ocspNotTrustedToAnchor
            case errSecRecordModified:
                self = .recordModified
            case errSecOCSPSignatureError:
                self = .ocspSignatureError
            case errSecOCSPNoSigner:
                self = .ocspNoSigner
            case errSecOCSPResponderMalformedReq:
                self = .ocspResponderMalformedReq
            case errSecOCSPResponderInternalError:
                self = .ocspResponderInternalError
            case errSecOCSPResponderTryLater:
                self = .ocspResponderTryLater
            case errSecOCSPResponderSignatureRequired:
                self = .ocspResponderSignatureRequired
            case errSecOCSPResponderUnauthorized:
                self = .ocspResponderUnauthorized
            case errSecOCSPResponseNonceMismatch:
                self = .ocspResponseNonceMismatch
            case errSecCodeSigningBadCertChainLength:
                self = .codeSigningBadCertChainLength
            case errSecCodeSigningNoBasicConstraints:
                self = .codeSigningNoBasicConstraints
            case errSecCodeSigningBadPathLengthConstraint:
                self = .codeSigningBadPathLengthConstraint
            case errSecCodeSigningNoExtendedKeyUsage:
                self = .codeSigningNoExtendedKeyUsage
            case errSecCodeSigningDevelopment:
                self = .codeSigningDevelopment
            case errSecResourceSignBadCertChainLength:
                self = .resourceSignBadCertChainLength
            case errSecResourceSignBadExtKeyUsage:
                self = .resourceSignBadExtKeyUsage
            case errSecTrustSettingDeny:
                self = .trustSettingDeny
            case errSecInvalidSubjectName:
                self = .invalidSubjectName
            case errSecUnknownQualifiedCertStatement:
                self = .unknownQualifiedCertStatement
            case errSecMobileMeRequestQueued:
                self = .mobileMeRequestQueued
            case errSecMobileMeRequestRedirected:
                self = .mobileMeRequestRedirected
            case errSecMobileMeServerError:
                self = .mobileMeServerError
            case errSecMobileMeServerNotAvailable:
                self = .mobileMeServerNotAvailable
            case errSecMobileMeServerAlreadyExists:
                self = .mobileMeServerAlreadyExists
            case errSecMobileMeServerServiceErr:
                self = .mobileMeServerServiceErr
            case errSecMobileMeRequestAlreadyPending:
                self = .mobileMeRequestAlreadyPending
            case errSecMobileMeNoRequestPending:
                self = .mobileMeNoRequestPending
            case errSecMobileMeCSRVerifyFailure:
                self = .mobileMeCSRVerifyFailure
            case errSecMobileMeFailedConsistencyCheck:
                self = .mobileMeFailedConsistencyCheck
            case errSecNotInitialized:
                self = .notInitialized
            case errSecInvalidHandleUsage:
                self = .invalidHandleUsage
            case errSecPVCReferentNotFound:
                self = .pvcReferentNotFound
            case errSecFunctionIntegrityFail:
                self = .functionIntegrityFail
            case errSecInternalError:
                self = .internalError
            case errSecMemoryError:
                self = .memoryError
            case errSecInvalidData:
                self = .invalidData
            case errSecMDSError:
                self = .mdsError
            case errSecInvalidPointer:
                self = .invalidPointer
            case errSecSelfCheckFailed:
                self = .selfCheckFailed
            case errSecFunctionFailed:
                self = .functionFailed
            case errSecModuleManifestVerifyFailed:
                self = .moduleManifestVerifyFailed
            case errSecInvalidGUID:
                self = .invalidGUID
            case errSecInvalidHandle:
                self = .invalidHandle
            case errSecInvalidDBList:
                self = .invalidDBList
            case errSecInvalidPassthroughID:
                self = .invalidPassthroughID
            case errSecInvalidNetworkAddress:
                self = .invalidNetworkAddress
            case errSecCRLAlreadySigned:
                self = .crlAlreadySigned
            case errSecInvalidNumberOfFields:
                self = .invalidNumberOfFields
            case errSecVerificationFailure:
                self = .verificationFailure
            case errSecUnknownTag:
                self = .unknownTag
            case errSecInvalidSignature:
                self = .invalidSignature
            case errSecInvalidName:
                self = .invalidName
            case errSecInvalidCertificateRef:
                self = .invalidCertificateRef
            case errSecInvalidCertificateGroup:
                self = .invalidCertificateGroup
            case errSecTagNotFound:
                self = .tagNotFound
            case errSecInvalidQuery:
                self = .invalidQuery
            case errSecInvalidValue:
                self = .invalidValue
            case errSecCallbackFailed:
                self = .callbackFailed
            case errSecACLDeleteFailed:
                self = .aclDeleteFailed
            case errSecACLReplaceFailed:
                self = .aclReplaceFailed
            case errSecACLAddFailed:
                self = .aclAddFailed
            case errSecACLChangeFailed:
                self = .aclChangeFailed
            case errSecInvalidAccessCredentials:
                self = .invalidAccessCredentials
            case errSecInvalidRecord:
                self = .invalidRecord
            case errSecInvalidACL:
                self = .invalidACL
            case errSecInvalidSampleValue:
                self = .invalidSampleValue
            case errSecIncompatibleVersion:
                self = .incompatibleVersion
            case errSecPrivilegeNotGranted:
                self = .privilegeNotGranted
            case errSecInvalidScope:
                self = .invalidScope
            case errSecPVCAlreadyConfigured:
                self = .pvcAlreadyConfigured
            case errSecInvalidPVC:
                self = .invalidPVC
            case errSecEMMLoadFailed:
                self = .emmLoadFailed
            case errSecEMMUnloadFailed:
                self = .emmUnloadFailed
            case errSecAddinLoadFailed:
                self = .addinLoadFailed
            case errSecInvalidKeyRef:
                self = .invalidKeyRef
            case errSecInvalidKeyHierarchy:
                self = .invalidKeyHierarchy
            case errSecAddinUnloadFailed:
                self = .addinUnloadFailed
            case errSecLibraryReferenceNotFound:
                self = .libraryReferenceNotFound
            case errSecInvalidAddinFunctionTable:
                self = .invalidAddinFunctionTable
            case errSecInvalidServiceMask:
                self = .invalidServiceMask
            case errSecModuleNotLoaded:
                self = .moduleNotLoaded
            case errSecInvalidSubServiceID:
                self = .invalidSubServiceID
            case errSecAttributeNotInContext:
                self = .attributeNotInContext
            case errSecModuleManagerInitializeFailed:
                self = .moduleManagerInitializeFailed
            case errSecModuleManagerNotFound:
                self = .moduleManagerNotFound
            case errSecEventNotificationCallbackNotFound:
                self = .eventNotificationCallbackNotFound
            case errSecInputLengthError:
                self = .inputLengthError
            case errSecOutputLengthError:
                self = .outputLengthError
            case errSecPrivilegeNotSupported:
                self = .privilegeNotSupported
            case errSecDeviceError:
                self = .deviceError
            case errSecAttachHandleBusy:
                self = .attachHandleBusy
            case errSecNotLoggedIn:
                self = .notLoggedIn
            case errSecAlgorithmMismatch:
                self = .algorithmMismatch
            case errSecKeyUsageIncorrect:
                self = .keyUsageIncorrect
            case errSecKeyBlobTypeIncorrect:
                self = .keyBlobTypeIncorrect
            case errSecKeyHeaderInconsistent:
                self = .keyHeaderInconsistent
            case errSecUnsupportedKeyFormat:
                self = .unsupportedKeyFormat
            case errSecUnsupportedKeySize:
                self = .unsupportedKeySize
            case errSecInvalidKeyUsageMask:
                self = .invalidKeyUsageMask
            case errSecUnsupportedKeyUsageMask:
                self = .unsupportedKeyUsageMask
            case errSecInvalidKeyAttributeMask:
                self = .invalidKeyAttributeMask
            case errSecUnsupportedKeyAttributeMask:
                self = .unsupportedKeyAttributeMask
            case errSecInvalidKeyLabel:
                self = .invalidKeyLabel
            case errSecUnsupportedKeyLabel:
                self = .unsupportedKeyLabel
            case errSecInvalidKeyFormat:
                self = .invalidKeyFormat
            case errSecUnsupportedVectorOfBuffers:
                self = .unsupportedVectorOfBuffers
            case errSecInvalidInputVector:
                self = .invalidInputVector
            case errSecInvalidOutputVector:
                self = .invalidOutputVector
            case errSecInvalidContext:
                self = .invalidContext
            case errSecInvalidAlgorithm:
                self = .invalidAlgorithm
            case errSecInvalidAttributeKey:
                self = .invalidAttributeKey
            case errSecMissingAttributeKey:
                self = .missingAttributeKey
            case errSecInvalidAttributeInitVector:
                self = .invalidAttributeInitVector
            case errSecMissingAttributeInitVector:
                self = .missingAttributeInitVector
            case errSecInvalidAttributeSalt:
                self = .invalidAttributeSalt
            case errSecMissingAttributeSalt:
                self = .missingAttributeSalt
            case errSecInvalidAttributePadding:
                self = .invalidAttributePadding
            case errSecMissingAttributePadding:
                self = .missingAttributePadding
            case errSecInvalidAttributeRandom:
                self = .invalidAttributeRandom
            case errSecMissingAttributeRandom:
                self = .missingAttributeRandom
            case errSecInvalidAttributeSeed:
                self = .invalidAttributeSeed
            case errSecMissingAttributeSeed:
                self = .missingAttributeSeed
            case errSecInvalidAttributePassphrase:
                self = .invalidAttributePassphrase
            case errSecMissingAttributePassphrase:
                self = .missingAttributePassphrase
            case errSecInvalidAttributeKeyLength:
                self = .invalidAttributeKeyLength
            case errSecMissingAttributeKeyLength:
                self = .missingAttributeKeyLength
            case errSecInvalidAttributeBlockSize:
                self = .invalidAttributeBlockSize
            case errSecMissingAttributeBlockSize:
                self = .missingAttributeBlockSize
            case errSecInvalidAttributeOutputSize:
                self = .invalidAttributeOutputSize
            case errSecMissingAttributeOutputSize:
                self = .missingAttributeOutputSize
            case errSecInvalidAttributeRounds:
                self = .invalidAttributeRounds
            case errSecMissingAttributeRounds:
                self = .missingAttributeRounds
            case errSecInvalidAlgorithmParms:
                self = .invalidAlgorithmParms
            case errSecMissingAlgorithmParms:
                self = .missingAlgorithmParms
            case errSecInvalidAttributeLabel:
                self = .invalidAttributeLabel
            case errSecMissingAttributeLabel:
                self = .missingAttributeLabel
            case errSecInvalidAttributeKeyType:
                self = .invalidAttributeKeyType
            case errSecMissingAttributeKeyType:
                self = .missingAttributeKeyType
            case errSecInvalidAttributeMode:
                self = .invalidAttributeMode
            case errSecMissingAttributeMode:
                self = .missingAttributeMode
            case errSecInvalidAttributeEffectiveBits:
                self = .invalidAttributeEffectiveBits
            case errSecMissingAttributeEffectiveBits:
                self = .missingAttributeEffectiveBits
            case errSecInvalidAttributeStartDate:
                self = .invalidAttributeStartDate
            case errSecMissingAttributeStartDate:
                self = .missingAttributeStartDate
            case errSecInvalidAttributeEndDate:
                self = .invalidAttributeEndDate
            case errSecMissingAttributeEndDate:
                self = .missingAttributeEndDate
            case errSecInvalidAttributeVersion:
                self = .invalidAttributeVersion
            case errSecMissingAttributeVersion:
                self = .missingAttributeVersion
            case errSecInvalidAttributePrime:
                self = .invalidAttributePrime
            case errSecMissingAttributePrime:
                self = .missingAttributePrime
            case errSecInvalidAttributeBase:
                self = .invalidAttributeBase
            case errSecMissingAttributeBase:
                self = .missingAttributeBase
            case errSecInvalidAttributeSubprime:
                self = .invalidAttributeSubprime
            case errSecMissingAttributeSubprime:
                self = .missingAttributeSubprime
            case errSecInvalidAttributeIterationCount:
                self = .invalidAttributeIterationCount
            case errSecMissingAttributeIterationCount:
                self = .missingAttributeIterationCount
            case errSecInvalidAttributeDLDBHandle:
                self = .invalidAttributeDLDBHandle
            case errSecMissingAttributeDLDBHandle:
                self = .missingAttributeDLDBHandle
            case errSecInvalidAttributeAccessCredentials:
                self = .invalidAttributeAccessCredentials
            case errSecMissingAttributeAccessCredentials:
                self = .missingAttributeAccessCredentials
            case errSecInvalidAttributePublicKeyFormat:
                self = .invalidAttributePublicKeyFormat
            case errSecMissingAttributePublicKeyFormat:
                self = .missingAttributePublicKeyFormat
            case errSecInvalidAttributePrivateKeyFormat:
                self = .invalidAttributePrivateKeyFormat
            case errSecMissingAttributePrivateKeyFormat:
                self = .missingAttributePrivateKeyFormat
            case errSecInvalidAttributeSymmetricKeyFormat:
                self = .invalidAttributeSymmetricKeyFormat
            case errSecMissingAttributeSymmetricKeyFormat:
                self = .missingAttributeSymmetricKeyFormat
            case errSecInvalidAttributeWrappedKeyFormat:
                self = .invalidAttributeWrappedKeyFormat
            case errSecMissingAttributeWrappedKeyFormat:
                self = .missingAttributeWrappedKeyFormat
            case errSecStagedOperationInProgress:
                self = .stagedOperationInProgress
            case errSecStagedOperationNotStarted:
                self = .stagedOperationNotStarted
            case errSecVerifyFailed:
                self = .verifyFailed
            case errSecQuerySizeUnknown:
                self = .querySizeUnknown
            case errSecBlockSizeMismatch:
                self = .blockSizeMismatch
            case errSecPublicKeyInconsistent:
                self = .publicKeyInconsistent
            case errSecDeviceVerifyFailed:
                self = .deviceVerifyFailed
            case errSecInvalidLoginName:
                self = .invalidLoginName
            case errSecAlreadyLoggedIn:
                self = .alreadyLoggedIn
            case errSecInvalidDigestAlgorithm:
                self = .invalidDigestAlgorithm
            case errSecInvalidCRLGroup:
                self = .invalidCRLGroup
            case errSecCertificateCannotOperate:
                self = .certificateCannotOperate
            case errSecCertificateExpired:
                self = .certificateExpired
            case errSecCertificateNotValidYet:
                self = .certificateNotValidYet
            case errSecCertificateRevoked:
                self = .certificateRevoked
            case errSecCertificateSuspended:
                self = .certificateSuspended
            case errSecInsufficientCredentials:
                self = .insufficientCredentials
            case errSecInvalidAction:
                self = .invalidAction
            case errSecInvalidAuthority:
                self = .invalidAuthority
            case errSecVerifyActionFailed:
                self = .verifyActionFailed
            case errSecInvalidCertAuthority:
                self = .invalidCertAuthority
            case errSecInvaldCRLAuthority:
                self = .invaldCRLAuthority
            case errSecInvalidCRLEncoding:
                self = .invalidCRLEncoding
            case errSecInvalidCRLType:
                self = .invalidCRLType
            case errSecInvalidCRL:
                self = .invalidCRL
            case errSecInvalidFormType:
                self = .invalidFormType
            case errSecInvalidID:
                self = .invalidID
            case errSecInvalidIdentifier:
                self = .invalidIdentifier
            case errSecInvalidIndex:
                self = .invalidIndex
            case errSecInvalidPolicyIdentifiers:
                self = .invalidPolicyIdentifiers
            case errSecInvalidTimeString:
                self = .invalidTimeString
            case errSecInvalidReason:
                self = .invalidReason
            case errSecInvalidRequestInputs:
                self = .invalidRequestInputs
            case errSecInvalidResponseVector:
                self = .invalidResponseVector
            case errSecInvalidStopOnPolicy:
                self = .invalidStopOnPolicy
            case errSecInvalidTuple:
                self = .invalidTuple
            case errSecMultipleValuesUnsupported:
                self = .multipleValuesUnsupported
            case errSecNotTrusted:
                self = .notTrusted
            case errSecNoDefaultAuthority:
                self = .noDefaultAuthority
            case errSecRejectedForm:
                self = .rejectedForm
            case errSecRequestLost:
                self = .requestLost
            case errSecRequestRejected:
                self = .requestRejected
            case errSecUnsupportedAddressType:
                self = .unsupportedAddressType
            case errSecUnsupportedService:
                self = .unsupportedService
            case errSecInvalidTupleGroup:
                self = .invalidTupleGroup
            case errSecInvalidBaseACLs:
                self = .invalidBaseACLs
            case errSecInvalidTupleCredendtials:
                self = .invalidTupleCredendtials
            case errSecInvalidEncoding:
                self = .invalidEncoding
            case errSecInvalidValidityPeriod:
                self = .invalidValidityPeriod
            case errSecInvalidRequestor:
                self = .invalidRequestor
            case errSecRequestDescriptor:
                self = .requestDescriptor
            case errSecInvalidBundleInfo:
                self = .invalidBundleInfo
            case errSecInvalidCRLIndex:
                self = .invalidCRLIndex
            case errSecNoFieldValues:
                self = .noFieldValues
            case errSecUnsupportedFieldFormat:
                self = .unsupportedFieldFormat
            case errSecUnsupportedIndexInfo:
                self = .unsupportedIndexInfo
            case errSecUnsupportedLocality:
                self = .unsupportedLocality
            case errSecUnsupportedNumAttributes:
                self = .unsupportedNumAttributes
            case errSecUnsupportedNumIndexes:
                self = .unsupportedNumIndexes
            case errSecUnsupportedNumRecordTypes:
                self = .unsupportedNumRecordTypes
            case errSecFieldSpecifiedMultiple:
                self = .fieldSpecifiedMultiple
            case errSecIncompatibleFieldFormat:
                self = .incompatibleFieldFormat
            case errSecInvalidParsingModule:
                self = .invalidParsingModule
            case errSecDatabaseLocked:
                self = .databaseLocked
            case errSecDatastoreIsOpen:
                self = .datastoreIsOpen
            case errSecMissingValue:
                self = .missingValue
            case errSecUnsupportedQueryLimits:
                self = .unsupportedQueryLimits
            case errSecUnsupportedNumSelectionPreds:
                self = .unsupportedNumSelectionPreds
            case errSecUnsupportedOperator:
                self = .unsupportedOperator
            case errSecInvalidDBLocation:
                self = .invalidDBLocation
            case errSecInvalidAccessRequest:
                self = .invalidAccessRequest
            case errSecInvalidIndexInfo:
                self = .invalidIndexInfo
            case errSecInvalidNewOwner:
                self = .invalidNewOwner
            case errSecInvalidModifyMode:
                self = .invalidModifyMode
            case errSecMissingRequiredExtension:
                self = .missingRequiredExtension
            case errSecExtendedKeyUsageNotCritical:
                self = .extendedKeyUsageNotCritical
            case errSecTimestampMissing:
                self = .timestampMissing
            case errSecTimestampInvalid:
                self = .timestampInvalid
            case errSecTimestampNotTrusted:
                self = .timestampNotTrusted
            case errSecTimestampServiceNotAvailable:
                self = .timestampServiceNotAvailable
            case errSecTimestampBadAlg:
                self = .timestampBadAlg
            case errSecTimestampBadRequest:
                self = .timestampBadRequest
            case errSecTimestampBadDataFormat:
                self = .timestampBadDataFormat
            case errSecTimestampTimeNotAvailable:
                self = .timestampTimeNotAvailable
            case errSecTimestampUnacceptedPolicy:
                self = .timestampUnacceptedPolicy
            case errSecTimestampUnacceptedExtension:
                self = .timestampUnacceptedExtension
            case errSecTimestampAddInfoNotAvailable:
                self = .timestampAddInfoNotAvailable
            case errSecTimestampSystemFailure:
                self = .timestampSystemFailure
            case errSecSigningTimeMissing:
                self = .signingTimeMissing
            case errSecTimestampRejection:
                self = .timestampRejection
            case errSecTimestampWaiting:
                self = .timestampWaiting
            case errSecTimestampRevocationWarning:
                self = .timestampRevocationWarning
            case errSecTimestampRevocationNotification:
                self = .timestampRevocationNotification
            case -99999:
                self = .unexpectedError
            default:
                self = .unhandledError(code: rawValue)
            }
        }

        public static let errorDomain = "PremierKit.SecretKeychain.error"

        public var errorCode: Int {
            return Int(rawValue)
        }

        public var errorUserInfo: [String : Any] {
            return [NSLocalizedDescriptionKey: description]
        }

    }

}

extension SecretKeychain.Status: CustomStringConvertible {

    public var description: String {
        switch self {
        case .success:
            return "No error."
        case .diskFull:
            return "The disk is full."
        case .io:
            return "I/O error (bummers)"
        case .opWr:
            return "File already open with with write permission"
        case .param:
            return "One or more parameters passed to a function were not valid."
        case .wrPerm:
            return "write permissions error"
        case .allocate:
            return "Failed to allocate memory."
        case .userCanceled:
            return "User canceled the operation."
        case .badReq:
            return "Bad parameter or invalid state for operation."
        case .notAvailable:
            return "No keychain is available. You may need to restart your computer."
        case .readOnly:
            return "This keychain cannot be modified."
        case .authFailed:
            return "The user name or passphrase you entered is not correct."
        case .noSuchKeychain:
            return "The specified keychain could not be found."
        case .invalidKeychain:
            return "The specified keychain is not a valid keychain file."
        case .duplicateKeychain:
            return "A keychain with the same name already exists."
        case .duplicateCallback:
            return "The specified callback function is already installed."
        case .invalidCallback:
            return "The specified callback function is not valid."
        case .duplicateItem:
            return "The specified item already exists in the keychain."
        case .itemNotFound:
            return "The specified item could not be found in the keychain."
        case .bufferTooSmall:
            return "There is not enough memory available to use the specified item."
        case .dataTooLarge:
            return "This item contains information which is too large or in a format that cannot be displayed."
        case .noSuchAttr:
            return "The specified attribute does not exist."
        case .invalidItemRef:
            return "The specified item is no longer valid. It may have been deleted from the keychain."
        case .invalidSearchRef:
            return "Unable to search the current keychain."
        case .noSuchClass:
            return "The specified item does not appear to be a valid keychain item."
        case .noDefaultKeychain:
            return "A default keychain could not be found."
        case .interactionNotAllowed:
            return "User interaction is not allowed."
        case .readOnlyAttr:
            return "The specified attribute could not be modified."
        case .wrongSecVersion:
            return "This keychain was created by a different version of the system software and cannot be opened."
        case .keySizeNotAllowed:
            return "This item specifies a key size which is too large."
        case .noStorageModule:
            return "A required component (data storage module) could not be loaded. You may need to restart your computer."
        case .noCertificateModule:
            return "A required component (certificate module) could not be loaded. You may need to restart your computer."
        case .noPolicyModule:
            return "A required component (policy module) could not be loaded. You may need to restart your computer."
        case .interactionRequired:
            return "User interaction is required, but is currently not allowed."
        case .dataNotAvailable:
            return "The contents of this item cannot be retrieved."
        case .dataNotModifiable:
            return "The contents of this item cannot be modified."
        case .createChainFailed:
            return "One or more certificates required to validate this certificate cannot be found."
        case .invalidPrefsDomain:
            return "The specified preferences domain is not valid."
        case .inDarkWake:
            return "In dark wake, no UI possible"
        case .aclNotSimple:
            return "The specified access control list is not in standard (simple) form."
        case .policyNotFound:
            return "The specified policy cannot be found."
        case .invalidTrustSetting:
            return "The specified trust setting is invalid."
        case .noAccessForItem:
            return "The specified item has no access control."
        case .invalidOwnerEdit:
            return "Invalid attempt to change the owner of this item."
        case .trustNotAvailable:
            return "No trust results are available."
        case .unsupportedFormat:
            return "Import/Export format unsupported."
        case .unknownFormat:
            return "Unknown format in import."
        case .keyIsSensitive:
            return "Key material must be wrapped for export."
        case .multiplePrivKeys:
            return "An attempt was made to import multiple private keys."
        case .passphraseRequired:
            return "Passphrase is required for import/export."
        case .invalidPasswordRef:
            return "The password reference was invalid."
        case .invalidTrustSettings:
            return "The Trust Settings Record was corrupted."
        case .noTrustSettings:
            return "No Trust Settings were found."
        case .pkcs12VerifyFailure:
            return "MAC verification failed during PKCS12 import (wrong password?)"
        case .invalidCertificate:
            return "This certificate could not be decoded."
        case .notSigner:
            return "A certificate was not signed by its proposed parent."
        case .decode:
            return "Unable to decode the provided data."
        case .missingEntitlement:
            return "Internal error when a required entitlement isn't present, client has neither application-identifier nor keychain-access-groups entitlements."
        case .serviceNotAvailable:
            return "The required service is not available."
        case .insufficientClientID:
            return "The client ID is not correct."
        case .deviceReset:
            return "A device reset has occurred."
        case .deviceFailed:
            return "A device failure has occurred."
        case .appleAddAppACLSubject:
            return "Adding an application ACL subject failed."
        case .applePublicKeyIncomplete:
            return "The public key is incomplete."
        case .appleSignatureMismatch:
            return "A signature mismatch has occurred."
        case .appleInvalidKeyStartDate:
            return "The specified key has an invalid start date."
        case .appleInvalidKeyEndDate:
            return "The specified key has an invalid end date."
        case .conversionError:
            return "A conversion error has occurred."
        case .appleSSLv2Rollback:
            return "A SSLv2 rollback error has occurred."
        case .quotaExceeded:
            return "The quota was exceeded."
        case .fileTooBig:
            return "The file is too big."
        case .invalidDatabaseBlob:
            return "The specified database has an invalid blob."
        case .invalidKeyBlob:
            return "The specified database has an invalid key blob."
        case .incompatibleDatabaseBlob:
            return "The specified database has an incompatible blob."
        case .incompatibleKeyBlob:
            return "The specified database has an incompatible key blob."
        case .hostNameMismatch:
            return "A host name mismatch has occurred."
        case .unknownCriticalExtensionFlag:
            return "There is an unknown critical extension flag."
        case .noBasicConstraints:
            return "No basic constraints were found."
        case .noBasicConstraintsCA:
            return "No basic CA constraints were found."
        case .invalidAuthorityKeyID:
            return "The authority key ID is not valid."
        case .invalidSubjectKeyID:
            return "The subject key ID is not valid."
        case .invalidKeyUsageForPolicy:
            return "The key usage is not valid for the specified policy."
        case .invalidExtendedKeyUsage:
            return "The extended key usage is not valid."
        case .invalidIDLinkage:
            return "The ID linkage is not valid."
        case .pathLengthConstraintExceeded:
            return "The path length constraint was exceeded."
        case .invalidRoot:
            return "The root or anchor certificate is not valid."
        case .crlExpired:
            return "The CRL has expired."
        case .crlNotValidYet:
            return "The CRL is not yet valid."
        case .crlNotFound:
            return "The CRL was not found."
        case .crlServerDown:
            return "The CRL server is down."
        case .crlBadURI:
            return "The CRL has a bad Uniform Resource Identifier."
        case .unknownCertExtension:
            return "An unknown certificate extension was encountered."
        case .unknownCRLExtension:
            return "An unknown CRL extension was encountered."
        case .crlNotTrusted:
            return "The CRL is not trusted."
        case .crlPolicyFailed:
            return "The CRL policy failed."
        case .idpFailure:
            return "The issuing distribution point was not valid."
        case .smimeEmailAddressesNotFound:
            return "An email address mismatch was encountered."
        case .smimeBadExtendedKeyUsage:
            return "The appropriate extended key usage for SMIME was not found."
        case .smimeBadKeyUsage:
            return "The key usage is not compatible with SMIME."
        case .smimeKeyUsageNotCritical:
            return "The key usage extension is not marked as critical."
        case .smimeNoEmailAddress:
            return "No email address was found in the certificate."
        case .smimeSubjAltNameNotCritical:
            return "The subject alternative name extension is not marked as critical."
        case .sslBadExtendedKeyUsage:
            return "The appropriate extended key usage for SSL was not found."
        case .ocspBadResponse:
            return "The OCSP response was incorrect or could not be parsed."
        case .ocspBadRequest:
            return "The OCSP request was incorrect or could not be parsed."
        case .ocspUnavailable:
            return "OCSP service is unavailable."
        case .ocspStatusUnrecognized:
            return "The OCSP server did not recognize this certificate."
        case .endOfData:
            return "An end-of-data was detected."
        case .incompleteCertRevocationCheck:
            return "An incomplete certificate revocation check occurred."
        case .networkFailure:
            return "A network failure occurred."
        case .ocspNotTrustedToAnchor:
            return "The OCSP response was not trusted to a root or anchor certificate."
        case .recordModified:
            return "The record was modified."
        case .ocspSignatureError:
            return "The OCSP response had an invalid signature."
        case .ocspNoSigner:
            return "The OCSP response had no signer."
        case .ocspResponderMalformedReq:
            return "The OCSP responder was given a malformed request."
        case .ocspResponderInternalError:
            return "The OCSP responder encountered an internal error."
        case .ocspResponderTryLater:
            return "The OCSP responder is busy, try again later."
        case .ocspResponderSignatureRequired:
            return "The OCSP responder requires a signature."
        case .ocspResponderUnauthorized:
            return "The OCSP responder rejected this request as unauthorized."
        case .ocspResponseNonceMismatch:
            return "The OCSP response nonce did not match the request."
        case .codeSigningBadCertChainLength:
            return "Code signing encountered an incorrect certificate chain length."
        case .codeSigningNoBasicConstraints:
            return "Code signing found no basic constraints."
        case .codeSigningBadPathLengthConstraint:
            return "Code signing encountered an incorrect path length constraint."
        case .codeSigningNoExtendedKeyUsage:
            return "Code signing found no extended key usage."
        case .codeSigningDevelopment:
            return "Code signing indicated use of a development-only certificate."
        case .resourceSignBadCertChainLength:
            return "Resource signing has encountered an incorrect certificate chain length."
        case .resourceSignBadExtKeyUsage:
            return "Resource signing has encountered an error in the extended key usage."
        case .trustSettingDeny:
            return "The trust setting for this policy was set to Deny."
        case .invalidSubjectName:
            return "An invalid certificate subject name was encountered."
        case .unknownQualifiedCertStatement:
            return "An unknown qualified certificate statement was encountered."
        case .mobileMeRequestQueued:
            return "The MobileMe request will be sent during the next connection."
        case .mobileMeRequestRedirected:
            return "The MobileMe request was redirected."
        case .mobileMeServerError:
            return "A MobileMe server error occurred."
        case .mobileMeServerNotAvailable:
            return "The MobileMe server is not available."
        case .mobileMeServerAlreadyExists:
            return "The MobileMe server reported that the item already exists."
        case .mobileMeServerServiceErr:
            return "A MobileMe service error has occurred."
        case .mobileMeRequestAlreadyPending:
            return "A MobileMe request is already pending."
        case .mobileMeNoRequestPending:
            return "MobileMe has no request pending."
        case .mobileMeCSRVerifyFailure:
            return "A MobileMe CSR verification failure has occurred."
        case .mobileMeFailedConsistencyCheck:
            return "MobileMe has found a failed consistency check."
        case .notInitialized:
            return "A function was called without initializing CSSM."
        case .invalidHandleUsage:
            return "The CSSM handle does not match with the service type."
        case .pvcReferentNotFound:
            return "A reference to the calling module was not found in the list of authorized callers."
        case .functionIntegrityFail:
            return "A function address was not within the verified module."
        case .internalError:
            return "An internal error has occurred."
        case .memoryError:
            return "A memory error has occurred."
        case .invalidData:
            return "Invalid data was encountered."
        case .mdsError:
            return "A Module Directory Service error has occurred."
        case .invalidPointer:
            return "An invalid pointer was encountered."
        case .selfCheckFailed:
            return "Self-check has failed."
        case .functionFailed:
            return "A function has failed."
        case .moduleManifestVerifyFailed:
            return "A module manifest verification failure has occurred."
        case .invalidGUID:
            return "An invalid GUID was encountered."
        case .invalidHandle:
            return "An invalid handle was encountered."
        case .invalidDBList:
            return "An invalid DB list was encountered."
        case .invalidPassthroughID:
            return "An invalid passthrough ID was encountered."
        case .invalidNetworkAddress:
            return "An invalid network address was encountered."
        case .crlAlreadySigned:
            return "The certificate revocation list is already signed."
        case .invalidNumberOfFields:
            return "An invalid number of fields were encountered."
        case .verificationFailure:
            return "A verification failure occurred."
        case .unknownTag:
            return "An unknown tag was encountered."
        case .invalidSignature:
            return "An invalid signature was encountered."
        case .invalidName:
            return "An invalid name was encountered."
        case .invalidCertificateRef:
            return "An invalid certificate reference was encountered."
        case .invalidCertificateGroup:
            return "An invalid certificate group was encountered."
        case .tagNotFound:
            return "The specified tag was not found."
        case .invalidQuery:
            return "The specified query was not valid."
        case .invalidValue:
            return "An invalid value was detected."
        case .callbackFailed:
            return "A callback has failed."
        case .aclDeleteFailed:
            return "An ACL delete operation has failed."
        case .aclReplaceFailed:
            return "An ACL replace operation has failed."
        case .aclAddFailed:
            return "An ACL add operation has failed."
        case .aclChangeFailed:
            return "An ACL change operation has failed."
        case .invalidAccessCredentials:
            return "Invalid access credentials were encountered."
        case .invalidRecord:
            return "An invalid record was encountered."
        case .invalidACL:
            return "An invalid ACL was encountered."
        case .invalidSampleValue:
            return "An invalid sample value was encountered."
        case .incompatibleVersion:
            return "An incompatible version was encountered."
        case .privilegeNotGranted:
            return "The privilege was not granted."
        case .invalidScope:
            return "An invalid scope was encountered."
        case .pvcAlreadyConfigured:
            return "The PVC is already configured."
        case .invalidPVC:
            return "An invalid PVC was encountered."
        case .emmLoadFailed:
            return "The EMM load has failed."
        case .emmUnloadFailed:
            return "The EMM unload has failed."
        case .addinLoadFailed:
            return "The add-in load operation has failed."
        case .invalidKeyRef:
            return "An invalid key was encountered."
        case .invalidKeyHierarchy:
            return "An invalid key hierarchy was encountered."
        case .addinUnloadFailed:
            return "The add-in unload operation has failed."
        case .libraryReferenceNotFound:
            return "A library reference was not found."
        case .invalidAddinFunctionTable:
            return "An invalid add-in function table was encountered."
        case .invalidServiceMask:
            return "An invalid service mask was encountered."
        case .moduleNotLoaded:
            return "A module was not loaded."
        case .invalidSubServiceID:
            return "An invalid subservice ID was encountered."
        case .attributeNotInContext:
            return "An attribute was not in the context."
        case .moduleManagerInitializeFailed:
            return "A module failed to initialize."
        case .moduleManagerNotFound:
            return "A module was not found."
        case .eventNotificationCallbackNotFound:
            return "An event notification callback was not found."
        case .inputLengthError:
            return "An input length error was encountered."
        case .outputLengthError:
            return "An output length error was encountered."
        case .privilegeNotSupported:
            return "The privilege is not supported."
        case .deviceError:
            return "A device error was encountered."
        case .attachHandleBusy:
            return "The CSP handle was busy."
        case .notLoggedIn:
            return "You are not logged in."
        case .algorithmMismatch:
            return "An algorithm mismatch was encountered."
        case .keyUsageIncorrect:
            return "The key usage is incorrect."
        case .keyBlobTypeIncorrect:
            return "The key blob type is incorrect."
        case .keyHeaderInconsistent:
            return "The key header is inconsistent."
        case .unsupportedKeyFormat:
            return "The key header format is not supported."
        case .unsupportedKeySize:
            return "The key size is not supported."
        case .invalidKeyUsageMask:
            return "The key usage mask is not valid."
        case .unsupportedKeyUsageMask:
            return "The key usage mask is not supported."
        case .invalidKeyAttributeMask:
            return "The key attribute mask is not valid."
        case .unsupportedKeyAttributeMask:
            return "The key attribute mask is not supported."
        case .invalidKeyLabel:
            return "The key label is not valid."
        case .unsupportedKeyLabel:
            return "The key label is not supported."
        case .invalidKeyFormat:
            return "The key format is not valid."
        case .unsupportedVectorOfBuffers:
            return "The vector of buffers is not supported."
        case .invalidInputVector:
            return "The input vector is not valid."
        case .invalidOutputVector:
            return "The output vector is not valid."
        case .invalidContext:
            return "An invalid context was encountered."
        case .invalidAlgorithm:
            return "An invalid algorithm was encountered."
        case .invalidAttributeKey:
            return "A key attribute was not valid."
        case .missingAttributeKey:
            return "A key attribute was missing."
        case .invalidAttributeInitVector:
            return "An init vector attribute was not valid."
        case .missingAttributeInitVector:
            return "An init vector attribute was missing."
        case .invalidAttributeSalt:
            return "A salt attribute was not valid."
        case .missingAttributeSalt:
            return "A salt attribute was missing."
        case .invalidAttributePadding:
            return "A padding attribute was not valid."
        case .missingAttributePadding:
            return "A padding attribute was missing."
        case .invalidAttributeRandom:
            return "A random number attribute was not valid."
        case .missingAttributeRandom:
            return "A random number attribute was missing."
        case .invalidAttributeSeed:
            return "A seed attribute was not valid."
        case .missingAttributeSeed:
            return "A seed attribute was missing."
        case .invalidAttributePassphrase:
            return "A passphrase attribute was not valid."
        case .missingAttributePassphrase:
            return "A passphrase attribute was missing."
        case .invalidAttributeKeyLength:
            return "A key length attribute was not valid."
        case .missingAttributeKeyLength:
            return "A key length attribute was missing."
        case .invalidAttributeBlockSize:
            return "A block size attribute was not valid."
        case .missingAttributeBlockSize:
            return "A block size attribute was missing."
        case .invalidAttributeOutputSize:
            return "An output size attribute was not valid."
        case .missingAttributeOutputSize:
            return "An output size attribute was missing."
        case .invalidAttributeRounds:
            return "The number of rounds attribute was not valid."
        case .missingAttributeRounds:
            return "The number of rounds attribute was missing."
        case .invalidAlgorithmParms:
            return "An algorithm parameters attribute was not valid."
        case .missingAlgorithmParms:
            return "An algorithm parameters attribute was missing."
        case .invalidAttributeLabel:
            return "A label attribute was not valid."
        case .missingAttributeLabel:
            return "A label attribute was missing."
        case .invalidAttributeKeyType:
            return "A key type attribute was not valid."
        case .missingAttributeKeyType:
            return "A key type attribute was missing."
        case .invalidAttributeMode:
            return "A mode attribute was not valid."
        case .missingAttributeMode:
            return "A mode attribute was missing."
        case .invalidAttributeEffectiveBits:
            return "An effective bits attribute was not valid."
        case .missingAttributeEffectiveBits:
            return "An effective bits attribute was missing."
        case .invalidAttributeStartDate:
            return "A start date attribute was not valid."
        case .missingAttributeStartDate:
            return "A start date attribute was missing."
        case .invalidAttributeEndDate:
            return "An end date attribute was not valid."
        case .missingAttributeEndDate:
            return "An end date attribute was missing."
        case .invalidAttributeVersion:
            return "A version attribute was not valid."
        case .missingAttributeVersion:
            return "A version attribute was missing."
        case .invalidAttributePrime:
            return "A prime attribute was not valid."
        case .missingAttributePrime:
            return "A prime attribute was missing."
        case .invalidAttributeBase:
            return "A base attribute was not valid."
        case .missingAttributeBase:
            return "A base attribute was missing."
        case .invalidAttributeSubprime:
            return "A subprime attribute was not valid."
        case .missingAttributeSubprime:
            return "A subprime attribute was missing."
        case .invalidAttributeIterationCount:
            return "An iteration count attribute was not valid."
        case .missingAttributeIterationCount:
            return "An iteration count attribute was missing."
        case .invalidAttributeDLDBHandle:
            return "A database handle attribute was not valid."
        case .missingAttributeDLDBHandle:
            return "A database handle attribute was missing."
        case .invalidAttributeAccessCredentials:
            return "An access credentials attribute was not valid."
        case .missingAttributeAccessCredentials:
            return "An access credentials attribute was missing."
        case .invalidAttributePublicKeyFormat:
            return "A public key format attribute was not valid."
        case .missingAttributePublicKeyFormat:
            return "A public key format attribute was missing."
        case .invalidAttributePrivateKeyFormat:
            return "A private key format attribute was not valid."
        case .missingAttributePrivateKeyFormat:
            return "A private key format attribute was missing."
        case .invalidAttributeSymmetricKeyFormat:
            return "A symmetric key format attribute was not valid."
        case .missingAttributeSymmetricKeyFormat:
            return "A symmetric key format attribute was missing."
        case .invalidAttributeWrappedKeyFormat:
            return "A wrapped key format attribute was not valid."
        case .missingAttributeWrappedKeyFormat:
            return "A wrapped key format attribute was missing."
        case .stagedOperationInProgress:
            return "A staged operation is in progress."
        case .stagedOperationNotStarted:
            return "A staged operation was not started."
        case .verifyFailed:
            return "A cryptographic verification failure has occurred."
        case .querySizeUnknown:
            return "The query size is unknown."
        case .blockSizeMismatch:
            return "A block size mismatch occurred."
        case .publicKeyInconsistent:
            return "The public key was inconsistent."
        case .deviceVerifyFailed:
            return "A device verification failure has occurred."
        case .invalidLoginName:
            return "An invalid login name was detected."
        case .alreadyLoggedIn:
            return "The user is already logged in."
        case .invalidDigestAlgorithm:
            return "An invalid digest algorithm was detected."
        case .invalidCRLGroup:
            return "An invalid CRL group was detected."
        case .certificateCannotOperate:
            return "The certificate cannot operate."
        case .certificateExpired:
            return "An expired certificate was detected."
        case .certificateNotValidYet:
            return "The certificate is not yet valid."
        case .certificateRevoked:
            return "The certificate was revoked."
        case .certificateSuspended:
            return "The certificate was suspended."
        case .insufficientCredentials:
            return "Insufficient credentials were detected."
        case .invalidAction:
            return "The action was not valid."
        case .invalidAuthority:
            return "The authority was not valid."
        case .verifyActionFailed:
            return "A verify action has failed."
        case .invalidCertAuthority:
            return "The certificate authority was not valid."
        case .invaldCRLAuthority:
            return "The CRL authority was not valid."
        case .invalidCRLEncoding:
            return "The CRL encoding was not valid."
        case .invalidCRLType:
            return "The CRL type was not valid."
        case .invalidCRL:
            return "The CRL was not valid."
        case .invalidFormType:
            return "The form type was not valid."
        case .invalidID:
            return "The ID was not valid."
        case .invalidIdentifier:
            return "The identifier was not valid."
        case .invalidIndex:
            return "The index was not valid."
        case .invalidPolicyIdentifiers:
            return "The policy identifiers are not valid."
        case .invalidTimeString:
            return "The time specified was not valid."
        case .invalidReason:
            return "The trust policy reason was not valid."
        case .invalidRequestInputs:
            return "The request inputs are not valid."
        case .invalidResponseVector:
            return "The response vector was not valid."
        case .invalidStopOnPolicy:
            return "The stop-on policy was not valid."
        case .invalidTuple:
            return "The tuple was not valid."
        case .multipleValuesUnsupported:
            return "Multiple values are not supported."
        case .notTrusted:
            return "The trust policy was not trusted."
        case .noDefaultAuthority:
            return "No default authority was detected."
        case .rejectedForm:
            return "The trust policy had a rejected form."
        case .requestLost:
            return "The request was lost."
        case .requestRejected:
            return "The request was rejected."
        case .unsupportedAddressType:
            return "The address type is not supported."
        case .unsupportedService:
            return "The service is not supported."
        case .invalidTupleGroup:
            return "The tuple group was not valid."
        case .invalidBaseACLs:
            return "The base ACLs are not valid."
        case .invalidTupleCredendtials:
            return "The tuple credentials are not valid."
        case .invalidEncoding:
            return "The encoding was not valid."
        case .invalidValidityPeriod:
            return "The validity period was not valid."
        case .invalidRequestor:
            return "The requestor was not valid."
        case .requestDescriptor:
            return "The request descriptor was not valid."
        case .invalidBundleInfo:
            return "The bundle information was not valid."
        case .invalidCRLIndex:
            return "The CRL index was not valid."
        case .noFieldValues:
            return "No field values were detected."
        case .unsupportedFieldFormat:
            return "The field format is not supported."
        case .unsupportedIndexInfo:
            return "The index information is not supported."
        case .unsupportedLocality:
            return "The locality is not supported."
        case .unsupportedNumAttributes:
            return "The number of attributes is not supported."
        case .unsupportedNumIndexes:
            return "The number of indexes is not supported."
        case .unsupportedNumRecordTypes:
            return "The number of record types is not supported."
        case .fieldSpecifiedMultiple:
            return "Too many fields were specified."
        case .incompatibleFieldFormat:
            return "The field format was incompatible."
        case .invalidParsingModule:
            return "The parsing module was not valid."
        case .databaseLocked:
            return "The database is locked."
        case .datastoreIsOpen:
            return "The data store is open."
        case .missingValue:
            return "A missing value was detected."
        case .unsupportedQueryLimits:
            return "The query limits are not supported."
        case .unsupportedNumSelectionPreds:
            return "The number of selection predicates is not supported."
        case .unsupportedOperator:
            return "The operator is not supported."
        case .invalidDBLocation:
            return "The database location is not valid."
        case .invalidAccessRequest:
            return "The access request is not valid."
        case .invalidIndexInfo:
            return "The index information is not valid."
        case .invalidNewOwner:
            return "The new owner is not valid."
        case .invalidModifyMode:
            return "The modify mode is not valid."
        case .missingRequiredExtension:
            return "A required certificate extension is missing."
        case .extendedKeyUsageNotCritical:
            return "The extended key usage extension was not marked critical."
        case .timestampMissing:
            return "A timestamp was expected but was not found."
        case .timestampInvalid:
            return "The timestamp was not valid."
        case .timestampNotTrusted:
            return "The timestamp was not trusted."
        case .timestampServiceNotAvailable:
            return "The timestamp service is not available."
        case .timestampBadAlg:
            return "An unrecognized or unsupported Algorithm Identifier in timestamp."
        case .timestampBadRequest:
            return "The timestamp transaction is not permitted or supported."
        case .timestampBadDataFormat:
            return "The timestamp data submitted has the wrong format."
        case .timestampTimeNotAvailable:
            return "The time source for the Timestamp Authority is not available."
        case .timestampUnacceptedPolicy:
            return "The requested policy is not supported by the Timestamp Authority."
        case .timestampUnacceptedExtension:
            return "The requested extension is not supported by the Timestamp Authority."
        case .timestampAddInfoNotAvailable:
            return "The additional information requested is not available."
        case .timestampSystemFailure:
            return "The timestamp request cannot be handled due to system failure."
        case .signingTimeMissing:
            return "A signing time was expected but was not found."
        case .timestampRejection:
            return "A timestamp transaction was rejected."
        case .timestampWaiting:
            return "A timestamp transaction is waiting."
        case .timestampRevocationWarning:
            return "A timestamp authority revocation warning was issued."
        case .timestampRevocationNotification:
            return "A timestamp authority revocation notification was issued."
        case .unexpectedError:
            return "Unexpected error has occurred."
        case .unhandledError(let code):
            return "Unhandled error with OS status: \(code)."
        }
    }

}
