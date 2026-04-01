package com.lht.component;

import com.nimbusds.jose.JWSVerifier;
import com.nimbusds.jose.crypto.MACVerifier;
import com.nimbusds.jwt.SignedJWT;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.util.Date;

@Component
public class JwtUtils {
    private static String SECRET;

    @Value("${jwt.secret}")
    public void setSecret(String secret) {
        JwtUtils.SECRET = secret;
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

    public static String getMail(String token) throws Exception {
        SignedJWT signedJWT = SignedJWT.parse(token);
        return signedJWT.getJWTClaimsSet().getSubject();
    }

    public static String getRole(String token) throws Exception {
        SignedJWT signedJWT = SignedJWT.parse(token);
        return signedJWT.getJWTClaimsSet().getStringClaim("role");
    }

    public static String getUuid(String token) throws Exception {
        SignedJWT signedJWT = SignedJWT.parse(token);
        return signedJWT.getJWTClaimsSet().getStringClaim("uuid");
    }
}