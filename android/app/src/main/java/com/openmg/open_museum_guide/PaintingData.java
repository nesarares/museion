package com.openmg.open_museum_guide;

import org.opencv.core.Mat;

public class PaintingData {
  private String id;
  private Mat phash;
  private Mat histogram;

  public PaintingData(String id, String phashBase64, String histogramBase64) {
    this.id = id;

    byte[] phashArray = (byte[]) SerializationUtils.fromBase64String(phashBase64);
    float[] histogramArray = (float[]) SerializationUtils.fromBase64String(histogramBase64);

    phash = new Mat(Constants.phashRows, Constants.phashCols, Constants.phashType);
    histogram = new Mat(Constants.histRows, Constants.histCols, Constants.histType);

    phash.put(0, 0, phashArray);
    histogram.put(0, 0, histogramArray);
  }

  @Override
  public String toString() {
    return "PaintingData{" +
        "\nid='" + id + '\'' +
        "\nphash=" + phash.dump() +
        "\nhistogram=" + histogram.dump() +
        "\n}";
  }
}
