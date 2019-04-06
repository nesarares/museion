package com.openmg.open_museum_guide;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.util.Log;

import org.opencv.android.Utils;
import org.opencv.core.CvType;
import org.opencv.core.Mat;
import org.opencv.core.MatOfFloat;
import org.opencv.core.MatOfInt;
import org.opencv.img_hash.PHash;
import org.opencv.imgcodecs.Imgcodecs;
import org.opencv.imgproc.Imgproc;

import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.util.PathUtils;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "com.openmg.open_museum_guide/opencv";
  private PHash pHashClass;

  static final int phashType = CvType.CV_8UC1;
  static final int phashRows = 1;
  static final int phashCols = 8;
  static final int histType = CvType.CV_32FC1;
  static final int histRows = 12;
  static final int histCols = 12;

  static class ImgData {
    String phash;
    String histogram;

    public ImgData(String phash, String histogram) {
      this.phash = phash;
      this.histogram = histogram;
    }
  }

  static {
    System.loadLibrary("opencv_java3");
  }

  private void print(String str) {
    Log.d("ANDROIDUS", str);
  }

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    pHashClass = PHash.create();

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
        (call, result) -> {
          switch (call.method) {
            case "runEdgeDetectionOnImage":
              runEdgeDetectionOnImage(call, result);
              break;
            case "generateImageData":
              generateImageData(call, result);
              break;
            default:
              result.notImplemented();
          }
        });
  }

  private ImgData getHashAndHistogram(Mat imgMat) {
    // Compute pHash
    Mat phashMat = new Mat();
    pHashClass.compute(imgMat, phashMat);

    // Compute histogram
    MatOfInt channels = new MatOfInt(0, 1);
    Mat mask = new Mat();
    Mat histMat = new Mat();
    MatOfInt histSize = new MatOfInt(histRows, histCols);
    MatOfFloat histRanges = new MatOfFloat(0f, 256f, 0f, 256f);

    Imgproc.calcHist(Arrays.asList(imgMat),
        channels,
        mask,
        histMat,
        histSize,
        histRanges);

    // Convert from Mat to base 65 strings
    byte[] phashArray = new byte[phashRows * phashCols];
    float[] histArray = new float[histRows * histCols];

    phashMat.get(0, 0, phashArray);
    histMat.get(0, 0, histArray);

    String phashBase64 = SerializationUtils.toBase64String(phashArray);
    String histBase64 = SerializationUtils.toBase64String(histArray);

    return new ImgData(phashBase64, histBase64);
  }

  private void generateImageData(MethodCall call, MethodChannel.Result result) {
    HashMap args = (HashMap) call.arguments;
    List<Map<String, String>> paintings = (List<Map<String, String>>) args.get("paintings");

    for (Map<String, String> painting : paintings) {
      String imagePath = painting.get("imagePath");
      String appDir = PathUtils.getDataDirectory(getApplicationContext());

      Mat imgMat = Imgcodecs.imread(appDir + "/" + imagePath);
      Imgproc.cvtColor(imgMat, imgMat, Imgproc.COLOR_BGR2RGB);

      ImgData imgData = getHashAndHistogram(imgMat);
      painting.put("phash", imgData.phash);
      painting.put("histogram", imgData.histogram);
      painting.remove("imagePath");
    }

    result.success(paintings);
  }

  private void runEdgeDetectionOnImage(MethodCall call, MethodChannel.Result result) {
    try {
      HashMap args = (HashMap) call.arguments;
      String path = args.get("path").toString();

      Log.d("ANDROIDUS", "tralala " + path);

      InputStream inputStream = null;
      inputStream = new FileInputStream(path.replace("file://", ""));

      BitmapFactory.Options bmpFactoryOptions = new BitmapFactory.Options();
      bmpFactoryOptions.inPreferredConfig = Bitmap.Config.ARGB_8888;

      Bitmap bitmapRaw = BitmapFactory.decodeStream(inputStream, null, bmpFactoryOptions);

      Mat imageMat = new Mat();
      Utils.bitmapToMat(bitmapRaw, imageMat);

      Log.d("ANDROIDUS", "tralala am incarcat imaginea");

      Mat phashMat = new Mat();
      pHashClass.compute(imageMat, phashMat);

      Log.d("ANDROIDUS", phashMat.dump());

      Mat gray = new Mat(imageMat.size(), CvType.CV_8UC1);
      Imgproc.cvtColor(imageMat, gray, Imgproc.COLOR_RGB2GRAY);
      Mat edge = new Mat();
      Mat dst = new Mat();
      Imgproc.Canny(gray, edge, 80, 90);
      Imgproc.cvtColor(edge, dst, Imgproc.COLOR_GRAY2RGBA, 4);
      Bitmap resultBitmap = Bitmap.createBitmap(dst.cols(), dst.rows(), Bitmap.Config.ARGB_8888);
      Utils.matToBitmap(dst, resultBitmap);

      ByteArrayOutputStream stream = new ByteArrayOutputStream();
      resultBitmap.compress(Bitmap.CompressFormat.PNG, 100, stream);
      byte[] byteArray = stream.toByteArray();
      resultBitmap.recycle();

      result.success(byteArray);
    } catch (FileNotFoundException e) {
      Log.d("ANDROIDUS", "tralala FILE NOT FOUND");
      e.printStackTrace();
    }
  }
}
