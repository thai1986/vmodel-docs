#include <gtest/gtest.h>
#include "../src/authentication_module.h"

/**
 * @brief Test fixture for AuthenticationModule testing
 * 
 * This test suite verifies the authentication module functionality
 * as specified in TC_UNIT_001 and related requirements.
 */
class AuthenticationModuleTest : public ::testing::Test {
protected:
    void SetUp() override {
        authModule = std::make_unique<AuthenticationModule>();
    }

    void TearDown() override {
        authModule.reset();
    }

    std::unique_ptr<AuthenticationModule> authModule;
};

/**
 * @brief Test successful authentication with valid credentials
 * 
 * Verifies REQ_001: System shall allow users to log in using secure credentials
 */
TEST_F(AuthenticationModuleTest, AuthenticateValidCredentials) {
    // Test valid credentials
    auto result = authModule->authenticateUser("admin", "password123");
    EXPECT_EQ(result, AuthenticationModule::AuthResult::SUCCESS);
    EXPECT_TRUE(authModule->isAuthenticated());
}

/**
 * @brief Test authentication failure with invalid credentials
 * 
 * Verifies that invalid credentials are properly rejected
 */
TEST_F(AuthenticationModuleTest, AuthenticateInvalidCredentials) {
    // Test invalid credentials
    auto result = authModule->authenticateUser("invalid", "wrongpass");
    EXPECT_EQ(result, AuthenticationModule::AuthResult::INVALID_CREDENTIALS);
    EXPECT_FALSE(authModule->isAuthenticated());
}

/**
 * @brief Test authentication with empty credentials
 * 
 * Verifies proper handling of empty/null input
 */
TEST_F(AuthenticationModuleTest, AuthenticateEmptyCredentials) {
    // Test empty username
    auto result1 = authModule->authenticateUser("", "password");
    EXPECT_EQ(result1, AuthenticationModule::AuthResult::INVALID_CREDENTIALS);
    
    // Test empty password
    auto result2 = authModule->authenticateUser("user", "");
    EXPECT_EQ(result2, AuthenticationModule::AuthResult::INVALID_CREDENTIALS);
    
    // Test both empty
    auto result3 = authModule->authenticateUser("", "");
    EXPECT_EQ(result3, AuthenticationModule::AuthResult::INVALID_CREDENTIALS);
    
    EXPECT_FALSE(authModule->isAuthenticated());
}

/**
 * @brief Test multiple user authentication scenarios
 * 
 * Verifies that different valid users can authenticate
 */
TEST_F(AuthenticationModuleTest, AuthenticateMultipleUsers) {
    // Test user 1
    auto result1 = authModule->authenticateUser("user", "userpass");
    EXPECT_EQ(result1, AuthenticationModule::AuthResult::SUCCESS);
    EXPECT_TRUE(authModule->isAuthenticated());
    
    // Logout and test user 2
    authModule->logout();
    EXPECT_FALSE(authModule->isAuthenticated());
    
    auto result2 = authModule->authenticateUser("test", "testpass");
    EXPECT_EQ(result2, AuthenticationModule::AuthResult::SUCCESS);
    EXPECT_TRUE(authModule->isAuthenticated());
}

/**
 * @brief Test OAuth2 token validation
 * 
 * Verifies DES_001: OAuth2 authentication implementation
 */
TEST_F(AuthenticationModuleTest, ValidateOAuth2Token) {
    // Test valid token
    EXPECT_TRUE(authModule->validateToken("valid_token_123"));
    EXPECT_TRUE(authModule->validateToken("admin_token_456"));
    
    // Test invalid token
    EXPECT_FALSE(authModule->validateToken("invalid_token"));
    EXPECT_FALSE(authModule->validateToken(""));
}

/**
 * @brief Test logout functionality
 * 
 * Verifies that logout properly clears authentication state
 */
TEST_F(AuthenticationModuleTest, LogoutFunctionality) {
    // First authenticate
    authModule->authenticateUser("admin", "password123");
    EXPECT_TRUE(authModule->isAuthenticated());
    
    // Then logout
    authModule->logout();
    EXPECT_FALSE(authModule->isAuthenticated());
}

/**
 * @brief Test initial authentication state
 * 
 * Verifies that module starts in unauthenticated state
 */
TEST_F(AuthenticationModuleTest, InitialState) {
    EXPECT_FALSE(authModule->isAuthenticated());
}

/**
 * @brief Performance test for authentication
 * 
 * Verifies that authentication completes within acceptable time
 * (Related to REQ_SW_001 timing requirements)
 */
TEST_F(AuthenticationModuleTest, AuthenticationPerformance) {
    auto start = std::chrono::high_resolution_clock::now();
    
    authModule->authenticateUser("admin", "password123");
    
    auto end = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start);
    
    // Authentication should complete within 10ms (as per requirements)
    EXPECT_LT(duration.count(), 10);
}

/**
 * @brief Main test runner
 */
int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}