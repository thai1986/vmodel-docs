#ifndef AUTHENTICATION_MODULE_H
#define AUTHENTICATION_MODULE_H

#include <string>
#include <memory>

/**
 * @brief Authentication module implementing OAuth2 protocol
 * 
 * This module provides secure user authentication functionality
 * as specified in REQ_001 and DES_001.
 */
class AuthenticationModule {
public:
    enum class AuthResult {
        SUCCESS,
        INVALID_CREDENTIALS,
        TOKEN_EXPIRED,
        NETWORK_ERROR,
        UNKNOWN_ERROR
    };

    /**
     * @brief Constructor
     */
    AuthenticationModule();

    /**
     * @brief Destructor
     */
    ~AuthenticationModule();

    /**
     * @brief Authenticate user with credentials
     * @param username User's username
     * @param password User's password
     * @return AuthResult indicating success or failure reason
     */
    AuthResult authenticateUser(const std::string& username, const std::string& password);

    /**
     * @brief Validate OAuth2 token
     * @param token OAuth2 access token
     * @return true if token is valid, false otherwise
     */
    bool validateToken(const std::string& token);

    /**
     * @brief Check if user is currently authenticated
     * @return true if user is authenticated, false otherwise
     */
    bool isAuthenticated() const;

    /**
     * @brief Logout current user
     */
    void logout();

private:
    struct Impl;
    std::unique_ptr<Impl> pImpl;
};

#endif // AUTHENTICATION_MODULE_H