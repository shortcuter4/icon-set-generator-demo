package com.demo.iconsetgeneratordemo.util;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;
import org.roaringbitmap.RoaringBitmap;

import java.io.*;

@Converter(autoApply = true)
public class RoaringBitmapConverter implements AttributeConverter<RoaringBitmap, byte[]> {

    @Override
    public byte[] convertToDatabaseColumn(RoaringBitmap attribute) {
        if (attribute == null) return null;
        try (ByteArrayOutputStream baos = new ByteArrayOutputStream()) {
            attribute.serialize(new DataOutputStream(baos));
            return baos.toByteArray();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public RoaringBitmap convertToEntityAttribute(byte[] dbData) {
        if (dbData == null) return null;
        try (ByteArrayInputStream bais = new ByteArrayInputStream(dbData)) {
            RoaringBitmap bitmap = new RoaringBitmap();
            bitmap.deserialize(new DataInputStream(bais));
            return bitmap;
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}