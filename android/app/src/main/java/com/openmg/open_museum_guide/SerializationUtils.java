package com.openmg.open_museum_guide;

import android.util.Base64;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;

public class SerializationUtils {
  public static String toBase64String(Object object) {
    try {
      ByteArrayOutputStream bo = new ByteArrayOutputStream();
      ObjectOutputStream so = new ObjectOutputStream(bo);
      so.writeObject(object);
      so.flush();
      return Base64.encodeToString(bo.toByteArray(), Base64.DEFAULT);
    } catch (Exception e) {
      return "";
    }
  }

  public static Object fromBase64String(String string) {
    try {
      byte b[] = Base64.decode(string, Base64.DEFAULT);
      ByteArrayInputStream bi = new ByteArrayInputStream(b);
      ObjectInputStream si = new ObjectInputStream(bi);
      return si.readObject();
    }
    catch (Exception e) {
      return null;
    }
  }
}
