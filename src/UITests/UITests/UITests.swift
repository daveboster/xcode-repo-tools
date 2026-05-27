//
//  UITests.swift
//  UITests
//
//  Created by David Boster on 5/27/26.
//
//  Required environment variables:
//  1. In Xcode, choose Product > Scheme > Edit Scheme.
//  2. Select Test > Arguments.
//  3. Add TEST_USERNAME and TEST_PASSWORD under Environment Variables.
//  4. Enable both variables before running the UI tests.
//

import XCTest

final class UITests: XCTestCase {

   override func setUpWithError() throws {
       continueAfterFailure = false
   }

   @MainActor
   func test_Login_With_Apple_Id() throws {
       let credentials = try testCredentials()

       let app = XCUIApplication()
       app.activate()
       XCUIDevice.shared.press(.home)
       XCUIDevice.shared.press(.home)
       XCUIDevice.shared.press(.home)

       let springboardApp = XCUIApplication(bundleIdentifier: "com.apple.springboard")
       springboardApp.icons["Settings"].firstMatch.tap()

       let preferencesApp = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
       preferencesApp.activate()
       preferencesApp.staticTexts["Sign in to access your iCloud data, the App Store, Apple services, and more."].firstMatch.tap()
       preferencesApp.staticTexts["Enter an email address or phone number and password then verify your identity."].firstMatch.tap()

       let usernameField = preferencesApp.textFields["username-field"].firstMatch
       usernameField.tap()
       usernameField.typeText(credentials.username)

       preferencesApp.typeText("\r")

       let passwordField = preferencesApp.secureTextFields["password-field"].firstMatch
       passwordField.tap()
       passwordField.typeText(credentials.password)

       preferencesApp.buttons.containing(.staticText, identifier: "Continue").firstMatch.tap()
       let userNameText = preferencesApp.staticTexts["Kell Maresh"].firstMatch
       XCTAssertTrue(userNameText.waitForExistence(timeout: 30))

       let emailText = preferencesApp.staticTexts[credentials.username].firstMatch
       XCTAssertTrue(emailText.waitForExistence(timeout: 30))
       XCUIDevice.shared.press(.home)
       XCUIDevice.shared.press(.home)
   }

   private func testCredentials() throws -> (username: String, password: String) {
       let username = try XCTUnwrap(
           nonTemplateValue(UITestCredentials.username),
           "Set UITestCredentials.username before running this UI test."
       )
       let password = try XCTUnwrap(
           nonTemplateValue(UITestCredentials.password),
           "Set UITestCredentials.password before running this UI test."
       )

       return (username, password)
   }

   private func nonTemplateValue(_ value: String) -> String? {
       value.hasPrefix("TEST_") ? nil : value
   }
}
