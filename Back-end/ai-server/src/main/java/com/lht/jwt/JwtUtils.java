package com.lht.jwt;

import com.nimbusds.jose.JWSVerifier;
import com.nimbusds.jose.crypto.MACVerifier;
import com.nimbusds.jwt.SignedJWT;

import java.util.Date;

public class JwtUtils {
    // SECRET nên được lưu bằng biến môi trường,
    private static final String SECRET = "12345678901234567890123456789012"; // 32 ký tự (AES key)

    public static String getUsername(String token) throws Exception {
        SignedJWT signedJWT = SignedJWT.parse(token);
        return signedJWT.getJWTClaimsSet().getSubject();
    }

    public static String getRole(String token) throws Exception {
        SignedJWT signedJWT = SignedJWT.parse(token);
        return (String) signedJWT.getJWTClaimsSet().getClaim("role");
    }

    public static boolean validateToken(String token) throws Exception {
        SignedJWT signedJWT = SignedJWT.parse(token);
        JWSVerifier verifier = new MACVerifier(SECRET);

        if (signedJWT.verify(verifier)) {
            Date expiration = signedJWT.getJWTClaimsSet().getExpirationTime();
            return expiration.after(new Date());
        }
        return false;
    }
}