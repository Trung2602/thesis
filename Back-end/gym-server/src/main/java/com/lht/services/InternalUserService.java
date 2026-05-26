package com.lht.services;

import java.util.UUID;

public interface InternalUserService {
    void deleteRelatedData(UUID uuid, String role);
}
