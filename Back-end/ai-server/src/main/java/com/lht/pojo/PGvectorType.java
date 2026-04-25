package com.lht.pojo;

import com.pgvector.PGvector;
import org.hibernate.engine.spi.SharedSessionContractImplementor;
import org.hibernate.usertype.UserType;

import java.io.Serializable;
import java.sql.*;
import java.util.Objects;

public class PGvectorType implements UserType<PGvector> {

    @Override
    public int getSqlType() {
        return Types.OTHER;
    }

    @Override
    public Class<PGvector> returnedClass() {
        return PGvector.class;
    }

    @Override
    public PGvector nullSafeGet(ResultSet rs, int position,
                                SharedSessionContractImplementor session,
                                Object owner) throws SQLException {
        String value = rs.getString(position);
        return value == null ? null : new PGvector(value);
    }

    @Override
    public void nullSafeSet(PreparedStatement st, PGvector value, int index,
                            SharedSessionContractImplementor session) throws SQLException {
        if (value == null) {
            st.setNull(index, Types.OTHER);
        } else {
            PGvector.addVectorType((Connection) st.getConnection().unwrap(org.postgresql.PGConnection.class));
            st.setObject(index, value, Types.OTHER);
        }
    }

    @Override
    public boolean equals(PGvector x, PGvector y) {
        return Objects.equals(x, y);
    }

    @Override
    public int hashCode(PGvector x) { return x.hashCode(); }

    @Override
    public PGvector deepCopy(PGvector value) { return value; }

    @Override
    public boolean isMutable() { return false; }

    @Override
    public Serializable disassemble(PGvector value) { return value.toString(); }

    @Override
    public PGvector assemble(Serializable cached, Object owner) {
        try {
            return new PGvector((String) cached);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
}