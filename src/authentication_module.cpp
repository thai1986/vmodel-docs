#include "authentication_module.h"
#include <unordered_set>
#include <chrono>

// Private implementation
struct AuthenticationModule::Impl {
    bool authenticated = false;
    std::string currentUser;
    std::unordered_set<std::string> validTokens;
    
    // Simulated valid credentials for testing
    std::unordered_set<std::string> validUsers = {
        "admin:password123",
        "user:userpass",
        "test:testpass"
    };
};

AuthenticationModule::AuthenticationModule() 
    : pImpl(std::make_unique<Impl>()) {
    // Initialize with some test tokens
    pImpl->validTokens.insert("valid_token_123");
    pImpl->validTokens.insert("admin_token_456");
}

AuthenticationModule::~AuthenticationModule() = default;

AuthenticationModule::AuthResult AuthenticationModule::authenticateUser(
    const std::string& username, 
    const std::string& password) {
    
    if (username.empty() || password.empty()) {
        return AuthResult::INVALID_CREDENTIALS;
    }
    
    std::string credentials = username + ":" + password;
    
    if (pImpl->validUsers.find(credentials) != pImpl->validUsers.end()) {
        pImpl->authenticated = true;
        pImpl->currentUser = username;
        return AuthResult::SUCCESS;
    }
    
    return AuthResult::INVALID_CREDENTIALS;
}

bool AuthenticationModule::validateToken(const std::string& token) {
    if (token.empty()) {
        return false;
    }
    
    return pImpl->validTokens.find(token) != pImpl->validTokens.end();
}

bool AuthenticationModule::isAuthenticated() const {
    return pImpl->authenticated;
}

void AuthenticationModule::logout() {
    pImpl->authenticated = false;
    pImpl->currentUser.clear();
}