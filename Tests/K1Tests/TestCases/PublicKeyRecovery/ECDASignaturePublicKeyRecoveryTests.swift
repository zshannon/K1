//
//  File.swift
//  
//
//  Created by Alexander Cyon on 2022-10-25.
//

import Foundation
@testable import K1
import XCTest

/// Test vectors:
/// https://gist.github.com/webmaster128/130b628d83621a33579751846699ed15
final class ECDASignaturePublicKeyRecoveryTests: XCTestCase {
    func testRecovery() throws {
        let vectors = try JSONDecoder().decode([RecoveryTestVector].self, from: vectorsJSON)
        for vector in vectors {
            let publicKeyUncompressed = try [UInt8](hex: vector.publicKeyUncompressed)
            let expectedPublicKey = try K1.PublicKey(
                wrapped: .init(uncompressedRaw: publicKeyUncompressed)
            )
            XCTAssertEqual(
                try [UInt8](hex: vector.publicKeyCompressed),
                try expectedPublicKey.rawRepresentation(format: .compressed)
            )
            let signatureData = try Data(hex: vector.signature)
            XCTAssertThrowsError(try ECDSASignatureNonRecoverable(
                rawRepresentation: signatureData
            ))
            let signature = try ECDSASignatureRecoverable(
                rawRepresentation: signatureData
            )
            XCTAssertEqual(Int32(vector.recoveryID), signature.recoveryID)
            let hashedMessage = try Data(hex: vector.hashMessage)
            
            let recoveredPublicKey = try signature.recoverPublicKey(
                messageThatWasSigned: hashedMessage
            )
            
            XCTAssertEqual(expectedPublicKey, recoveredPublicKey)
        }
    }
}
struct RecoveryTestVector: Decodable, Equatable {
    let recoveryID: Int
    let message: String
    let hashMessage: String
    let signature: String
    let publicKeyUncompressed: String
    let publicKeyCompressed: String
}
private let vectorsJSON = """
[
    {
        "recoveryID": 1,
        "message": "5c868fedb8026979ebd26f1ba07c27eedf4ff6d10443505a96ecaf21ba8c4f0937b3cd23ffdc3dd429d4cd1905fb8dbcceeff1350020e18b58d2ba70887baa3a9b783ad30d3fbf210331cdd7df8d77defa398cdacdfc2e359c7ba4cae46bb74401deb417f8b912a1aa966aeeba9c39c7dd22479ae2b30719dca2f2206c5eb4b7",
        "hashMessage": "5ae8317d34d1e595e3fa7247db80c0af4320cce1116de187f8f7e2e099c0d8d0",
        "signature": "45c0b7f8c09a9e1f1cea0c25785594427b6bf8f9f878a8af0b1abbb48e16d0920d8becd0c220f67c51217eecfd7184ef0732481c843857e6bc7fc095c4f6b78801",
        "publicKeyUncompressed": "044a071e8a6e10aada2b8cf39fa3b5fb3400b04e99ea8ae64ceea1a977dbeaf5d5f8c8fbd10b71ab14cd561f7df8eb6da50f8a8d81ba564342244d26d1d4211595",
        "publicKeyCompressed": "034a071e8a6e10aada2b8cf39fa3b5fb3400b04e99ea8ae64ceea1a977dbeaf5d5"
    },
    {
        "recoveryID": 1,
        "message": "17cd4a74d724d55355b6fb2b0759ca095298e3fd1856b87ca1cb2df5409058022736d21be071d820b16dfc441be97fbcea5df787edc886e759475469e2128b22f26b82ca993be6695ab190e673285d561d3b6d42fcc1edd6d12db12dcda0823e9d6079e7bc5ff54cd452dad308d52a15ce9c7edd6ef3dad6a27becd8e001e80f",
        "hashMessage": "586052916fb6f746e1d417766cceffbe1baf95579bab67ad49addaaa6e798862",
        "signature": "4e0ea79d4a476276e4b067facdec7460d2c98c8a65326a6e5c998fd7c65061140e45aea5034af973410e65cf97651b3f2b976e3fc79c6a93065ed7cb69a2ab5a01",
        "publicKeyUncompressed": "04dbf1f4092deb3cfd4246b2011f7b24840bc5dbedae02f28471ce5b3bfbf06e71b320e42149e6d12ed8c717c5990359bb4f9bded9de674375b2f0ca0268748c8e",
        "publicKeyCompressed": "02dbf1f4092deb3cfd4246b2011f7b24840bc5dbedae02f28471ce5b3bfbf06e71"
    },
    {
        "recoveryID": 0,
        "message": "db0d31717b04802adbbae1997487da8773440923c09b869e12a57c36dda34af11b8897f266cd81c02a762c6b74ea6aaf45aaa3c52867eb8f270f5092a36b498f88b65b2ebda24afe675da6f25379d1e194d093e7a2f66e450568dbdffebff97c4597a00c96a5be9ba26deefcca8761c1354429622c8db269d6a0ec0cc7a8585c",
        "hashMessage": "c36d0ecf4bfd178835c97aae7585f6a87de7dfa23cc927944f99a8d60feff68b",
        "signature": "f25b86e1d8a11d72475b3ed273b0781c7d7f6f9e1dae0dd5d3ee9b84f3fab89163d9c4e1391de077244583e9a6e3d8e8e1f236a3bf5963735353b93b1a3ba93500",
        "publicKeyUncompressed": "04414549fd05bfb7803ae507ff86b99becd36f8d66037a7f5ba612792841d42eb959a0799bcdaa3b5e106f50add1ec4edf6e03fca8642a6a1c65ae078287eec9a5",
        "publicKeyCompressed": "03414549fd05bfb7803ae507ff86b99becd36f8d66037a7f5ba612792841d42eb9"
    },
    {
        "recoveryID": 1,
        "message": "47c9deddfd8c841a63a99be96e972e40fa035ae10d929babfc86c437b9d5d495577a45b7f8a35ce3f880e7d8ae8cd8eb685cf41f0506e68046ccf5559232c674abb9c3683829dcc8002683c4f4ca3a29a7bfde20d96dd0f1a0ead847dea18f297f220f94932536ca4deacedc2c6701c3ee50e28e358dcc54cdbf69daf0eb87f6",
        "hashMessage": "a761293b02c5d8327f909d61a38173556c1f1f770c488810a9b360cf7786c148",
        "signature": "f2cab57d108aaf7c9c9dd061404447d59f968d1468b25dd827d624b64601c32a77558dbf7bf90885b9128c371959085e9dd1b7d8a5c45b7265e8e7d9f125c00801",
        "publicKeyUncompressed": "041074702a456f9247ea07967b07d3b8def64aa932d80027dc90df74578a522504152f51ab5a5937d7bb82f38877ece243db6c0e894bfa46fe19c5b7abff4247b4",
        "publicKeyCompressed": "021074702a456f9247ea07967b07d3b8def64aa932d80027dc90df74578a522504"
    },
    {
        "recoveryID": 0,
        "message": "f15433188c2bbc93b2150bb2f34d36ba8ae49f8f7e4e81aed651c8fb2022b2a7e851c4dbbbc21c14e27380316bfdebb0a049246349537dba687581c1344e40f75afd2735bb21ea074861de6801d28b22e8beb76fdd25598812b2061ca3fba229daf59a4ab416704543b02e16b8136c22acc7e197748ae19b5cbbc160fdc3a8cd",
        "hashMessage": "08ec76ab0f1bc9dc27b3b3bd4f949c60ecc8bbf27678b28f2ee8de055ee8bf59",
        "signature": "d702bec0f058f5e18f5fcdb204f79250562f11121f5513ae1006c9b93ddafb1163de551c508405a280a21fb007b660542b58fcd3256b7cea45e3f2ebe9a29ecd00",
        "publicKeyUncompressed": "0482bdcaa5613930c51b993443a5dfaad41cf9b3d77e7a224283ffa96d0d546bdc8b2f6841a9d41e9fdf33de9f79f45323ad030e52c914ad3df36e95a4d4eef527",
        "publicKeyCompressed": "0382bdcaa5613930c51b993443a5dfaad41cf9b3d77e7a224283ffa96d0d546bdc"
    },
    {
        "recoveryID": 1,
        "message": "1bc796124b87793b7f7fdd53b896f8f0d0f2d2be36d1944e3c2a0ac5c6b2839f59a4b4fad200f8035ec98630c51ef0d40863a5ddd69b703d73f06b4afae8ad1a88e19b1b26e8c10b7bff953c05eccc82fd771b220910165f3a906b7c931683e431998d1fd06c32dd11b4f872bf980d547942f22124c7e50c9523321aee23a36d",
        "hashMessage": "ffbe3fd342a1a991848d02258cf5e3df301974b7a8f0fe10a88222a9503f67e0",
        "signature": "ae17ab6a3bd2ccd0901cc3904103e825895540bf416a5f717b74b529512e4c184bc049a8a2287cfccea77fb3769755ba92c35154c635448cf633244edf4f6fe101",
        "publicKeyUncompressed": "047dfd5be333e217f99b7b936452499f34a937268f1131d3ea36aa0fae7f6ccb177b68596c7db85ffe71a1d918f2c95a573a9735d3088b25cb53f57b6b8f1c24a3",
        "publicKeyCompressed": "037dfd5be333e217f99b7b936452499f34a937268f1131d3ea36aa0fae7f6ccb17"
    },
    {
        "recoveryID": 0,
        "message": "18e55ac264031da435b613fc9dc6c4aafc49aae8ddf6f220d523415896ff915fae5c5b2e6aed61d88e5721823f089c46173afc5d9b47fd917834c85284f62dda6ed2d7a6ff10eb553b9312b05dad7decf7f73b69479c02f14ea0a2aa9e05ec07396cd37c28795c90e590631137102315635d702278e352aa41d0826adadff5e1",
        "hashMessage": "434fea583df79f781e41f18735a24409cf404f28e930290cc97c67ef158e5789",
        "signature": "03b51d02eac41f2969fc36c816c9772da21a139376b09d1c8809bb8f543be62f0629c1396ae304d2c2e7b63890d91e56dfc3459f4d664cb914c7ff2a12a2192500",
        "publicKeyUncompressed": "04b3c3074d378b98b1fa1456dc83611512bc7f351c90e4cf083dce80fd8c4e95693d88c8538194701bbc6e217046080755bf76e45a7d77a689f0368d6bd8b4d41c",
        "publicKeyCompressed": "02b3c3074d378b98b1fa1456dc83611512bc7f351c90e4cf083dce80fd8c4e9569"
    },
    {
        "recoveryID": 1,
        "message": "a5290666c97294d090f8da898e555cbd33990579e5e95498444bfb318b4aa1643e0d4348425e21c7c6f99f9955f3048f56c22b68c4a516af5c90ed5268acc9c5a20fec0200c2a282a90e20d3c46d4ecdda18ba18b803b19263de2b79238da921707a0864799cdee9f02913b40681c02c6923070688844b58fe415b7d71ea6845",
        "hashMessage": "c352f58e118fc0d7810b8020bdb306b7dc115b41bbb0b642c7ea73a60cc2a4eb",
        "signature": "400f52f4c4925b4b8886706331535230fafb6455c3a3eef6fbf19a8259381230727cc4b3341d7d95d0dc404d910dc009b3b5f21baadc0c4ee199a46e558d7f5601",
        "publicKeyUncompressed": "043edd1cfab2ad7d0ba623a5780c3fa31b71031aa2cdbbde3b90199c06285a3848966377a8c08645abcc07a9c911460a6fef73801e1330970c8727fda9e7488172",
        "publicKeyCompressed": "023edd1cfab2ad7d0ba623a5780c3fa31b71031aa2cdbbde3b90199c06285a3848"
    },
    {
        "recoveryID": 0,
        "message": "13ad0600229c2a66b2f11617f69c7210ad044c49265dc98ec3c64f56e56a083234d277d404e2c40523c414ad23af5cc2f91a47fe59e7ca572f7fe1d3d3cfceaedadac4396749a292a38e92727273272335f12b2acea21cf069682e67d7e7d7a31ab5bb8e472298a9451aeae6f160f36e6623c9b632b9c93371a002818addc243",
        "hashMessage": "6ff9153ede285fc0e486f1dd4dd9e32a0fb23e9653c55841b67c2e5a090aac63",
        "signature": "b2927afc8856b7e14d02e01e7aa3c76951a4621bfde5d794adda165b51dbe19806eee6e0b087143ed06933cba699fbe4097ba7d7b038b173cbbd183718a86d4300",
        "publicKeyUncompressed": "045ea6df29756aad4c249d7432c0573308aa4be0666bf321e791795cdf41627d74f6aa44de02570075eec50bb6ac1e7d8a38fcf7aadafdc68badcc78b846ca3003",
        "publicKeyCompressed": "035ea6df29756aad4c249d7432c0573308aa4be0666bf321e791795cdf41627d74"
    },
    {
        "recoveryID": 0,
        "message": "51ad843da5eafc177d49a50a82609555e52773c5dfa14d7c02db5879c11a6b6e2e0860df38452dc579d763f91a83ade23b73f4fcbd703f35dd6ecfbb4c9578d5b604ed809c8633e6ac5679a5f742ce94fea3b97b5ba8a29ea28101a7b35f9eaa894dda54e3431f2464d18faf8342b7c59dfe0598c0ab29a14622a08eea70126b",
        "hashMessage": "8e19143e34fee546fab3d56e816f2e21586e27912a2ad7d80af75942e0ff585a",
        "signature": "fe9717965673fbe585780e18d892a3cfa77b59ac2f44f5337a3e58ce6ecd440900155459b19d2e9a2e676d7d8d48a9303391ffb9befdd3a57324306d69e0e0ab00",
        "publicKeyUncompressed": "04968de976bab658da49e4f8f629aa515dbe117de8e0d602477fcf0427e1a6944b4dbbff053f864ad7d5771e6a38f6f0df38b56a4e8d9caf9724a09b8cc8c4f843",
        "publicKeyCompressed": "03968de976bab658da49e4f8f629aa515dbe117de8e0d602477fcf0427e1a6944b"
    }
]
""".data(using: .utf8)!
