//
//  Copyright Microsoft Corporation
//

import XCTest
@testable import OfficeUIFabric

class AvatarViewTests: XCTestCase {
	func testValidInitialsCharacter () {
		XCTAssertTrue(Character("A").isValidInitialsCharacter)
		XCTAssertTrue(Character("Æ").isValidInitialsCharacter)
		XCTAssertTrue(Character("È").isValidInitialsCharacter)
		// same as above but with separate unicode scalars for the base character and the diacritic
		XCTAssertTrue(Character("E\u{0300}").isValidInitialsCharacter) // È
		XCTAssertTrue(Character("Å").isValidInitialsCharacter)
		XCTAssertTrue(Character("Ü").isValidInitialsCharacter)
		XCTAssertFalse(Character("😂").isValidInitialsCharacter)
		XCTAssertFalse(Character("👑").isValidInitialsCharacter)
		XCTAssertFalse(Character("王").isValidInitialsCharacter)
		XCTAssertFalse(Character("肖").isValidInitialsCharacter)
		XCTAssertFalse(Character("보").isValidInitialsCharacter)
		XCTAssertFalse(Character("").isValidInitialsCharacter)
		
		// Character with diacritic not available in Mac OS Roman
		XCTAssertFalse(Character("U\u{0304}").isValidInitialsCharacter) // Ū
	}

	func testInitialsExtraction () {
		// Basic cases
		XCTAssertEqual(initials(name: nil, email: nil), "#")
		XCTAssertEqual(initials(name: "Satya Nadella", email: nil), "SN")
		XCTAssertEqual(initials(name: "Satya Nadella", email: "satya@microsoft.com"), "SN")
		XCTAssertEqual(initials(name: nil, email: "satya@microsoft.com"), "S")
		XCTAssertEqual(initials(name: "Nick Goose Bradshaw", email: nil), "NG")
		XCTAssertEqual(initials(name: "Mike \"Viper\" Metcalf", email: nil), "MM")
		
		// Non-standard characters
		XCTAssertEqual(initials(name: "😂", email: "happy@sevendwarves.net"), "H")
		XCTAssertEqual(initials(name: "🧐", email: "😀@😬.😂"), "#")
		XCTAssertEqual(initials(name: "☮︎", email: nil), "#")
		XCTAssertEqual(initials(name: "Satya Nadella 👑", email: "satya@microsoft.com"), "SN")
		XCTAssertEqual(initials(name: "Satya Nadella👑", email: "satya@microsoft.com"), "SN")
		XCTAssertEqual(initials(name: "Satya 👑 Nadella", email: "satya@microsoft.com"), "SN")

		// Complex characters
		XCTAssertEqual(initials(name: "王小博", email: "email@host.com"), "E")
		XCTAssertEqual(initials(name: "王小博", email: nil), "#")
		XCTAssertEqual(initials(name: "肖赞", email: ""), "#")
		XCTAssertEqual(initials(name: "보라", email: nil), "#")
		XCTAssertEqual(initials(name: "אָדָם", email: nil), "#")
		XCTAssertEqual(initials(name: "حسن", email: nil), "#")
		XCTAssertEqual(initials(name: nil, email: "用户@例子.广告"), "#")

		// Complex roman characters
		XCTAssertEqual(initials(name: "Êmïlÿ Çœłb", email: nil), "ÊÇ")
		
		// Complex roman characters with alternate unicode representation
		XCTAssertEqual("E\u{0300}", "È")
		XCTAssertEqual(initials(name: "E\u{0300}mïlÿ Çœłb", email: nil), "ÈÇ")

		// Mixed characters
		XCTAssertEqual(initials(name: "Sean 肖", email: nil), "S")
		
		// Whitespace
		XCTAssertEqual(initials(name: " Satya Nadella ", email: nil), "SN")
		XCTAssertEqual(initials(name: "\nSatya Nadella\n", email: nil), "SN")
		XCTAssertEqual(initials(name: "\tSatya Nadella ", email: nil), "SN")
		XCTAssertEqual(initials(name: "Satya Nadella\n", email: nil), "SN")
		
		// Zero Width Space
		XCTAssertEqual(initials(name: "Jane\u{200B}Doe", email: nil), "J")
		XCTAssertEqual(initials(name: "\u{200B}Jane\u{200B} \u{200B}Doe\u{200B}", email: nil), "JD")
	}
	
	func testAccessibility () {
		// Avatar with name and email should be an accessibility element with the ax label and tooltip set to the contactName with an image role
		let satya = AvatarView(avatarSize: 0, contactName: "Satya Nadella", contactEmail: "satya@microsoft.com")
		XCTAssertTrue(satya.isAccessibilityElement())
		XCTAssertEqual(satya.accessibilityLabel(), "Satya Nadella")
		XCTAssertEqual(satya.accessibilityRole(), NSAccessibility.Role.image)
		XCTAssertEqual(satya.toolTip, "Satya Nadella")
		
		// When no name is provided, the ax label and tooltip should fallback to the contactEmail
		let noNameSatya = AvatarView(avatarSize: 0, contactEmail: "satya@microsoft.com")
		XCTAssertTrue(noNameSatya.isAccessibilityElement())
		XCTAssertEqual(noNameSatya.accessibilityLabel(), "satya@microsoft.com")
		XCTAssertEqual(noNameSatya.accessibilityRole(), NSAccessibility.Role.image)
		XCTAssertEqual(noNameSatya.toolTip, "satya@microsoft.com")
		
		// When no name or email is provided, there isn't any valuable information to provide, so don't be an accessibility element
		let anonymousAvatar = AvatarView(avatarSize: 0)
		XCTAssertFalse(anonymousAvatar.isAccessibilityElement())
		XCTAssertNil(anonymousAvatar.accessibilityLabel())
		XCTAssertEqual(anonymousAvatar.accessibilityRole(), NSAccessibility.Role.unknown)
		XCTAssertNil(anonymousAvatar.toolTip)
	}

	func testColorTable () {
		// Cherry pick a few known values and test them
		XCTAssertEqual(AvatarView.backgroundColor(for: 0), #colorLiteral(red: 0.6, green: 0.71, blue: 0.2, alpha: 1))
		XCTAssertEqual(AvatarView.backgroundColor(for: 1887), #colorLiteral(red: 0.85, green: 0.32, blue: 0.17, alpha: 1))
		XCTAssertEqual(AvatarView.backgroundColor(for: 2268), #colorLiteral(red: 0.6, green: 0.71, blue: 0.2, alpha: 1))
		XCTAssertEqual(AvatarView.backgroundColor(for: 3986), #colorLiteral(red: 0.17, green: 0.34, blue: 0.59, alpha: 1))
	}

	func testHashAlgorithm () {
		XCTAssertEqual(colorIndex(for: "satya@microsoft.com"), 8387)
		XCTAssertEqual(colorIndex(for: "maverick@miramar.edu"), 3986)
		XCTAssertEqual(colorIndex(for: "goose@miramar.edu"), 2268)
		XCTAssertEqual(colorIndex(for: "cblackwood@civiliancontractor.com"), 1886)
		XCTAssertEqual(colorIndex(for: "Tom Kazansky"), 9318)
		XCTAssertEqual(colorIndex(for: ""), 0)
	}
}
