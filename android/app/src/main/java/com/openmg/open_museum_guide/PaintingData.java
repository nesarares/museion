package com.openmg.open_museum_guide;

import org.opencv.core.Mat;

public class PaintingData {
  public String id;
  public Mat phash;
  public Mat keypointDescriptors;

  public PaintingData(String id, String phashBase64, String keypointDescriptorsBase64) {
    this.id = id;

    byte[] phashArray = (byte[]) SerializationUtils.fromBase64String(phashBase64);
    byte[] descriptorsArray = (byte[]) SerializationUtils.fromBase64String(keypointDescriptorsBase64);

    phash = new Mat(Constants.phashRows, Constants.phashCols, Constants.phashType);
    keypointDescriptors = new Mat(Constants.descriptorRows, Constants.descriptorCols, Constants.descriptorType);

    phash.put(0, 0, phashArray);
    keypointDescriptors.put(0, 0, descriptorsArray);
  }

  @Override
  public String toString() {
    return "PaintingData{" +
        "\nid='" + id + '\'' +
        "\nphash=" + phash.dump() +
        "\ndescriptors=" + keypointDescriptors.dump() +
        "\n}";
  }
}
