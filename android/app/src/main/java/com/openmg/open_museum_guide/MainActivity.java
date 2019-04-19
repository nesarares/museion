package com.openmg.open_museum_guide;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.util.Log;
import android.util.Pair;

import org.opencv.android.Utils;
import org.opencv.core.CvType;
import org.opencv.core.DMatch;
import org.opencv.core.Mat;
import org.opencv.core.MatOfDMatch;
import org.opencv.core.MatOfFloat;
import org.opencv.core.MatOfInt;
import org.opencv.core.MatOfKeyPoint;
import org.opencv.features2d.DescriptorMatcher;
import org.opencv.features2d.ORB;
import org.opencv.img_hash.PHash;
import org.opencv.imgcodecs.Imgcodecs;
import org.opencv.imgproc.Imgproc;

import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
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
  private ORB orb;
  private DescriptorMatcher matcher;

  private Map<String, PaintingData> paintingDataList;

  static class ImgDataString {
    String phash;
    String descriptors;

    public ImgDataString(String phash, String descriptors) {
      this.phash = phash;
      this.descriptors = descriptors;
    }
  }

  static class ImgDataMat {
    Mat phash;
    Mat descriptors;

    public ImgDataMat(Mat phash, Mat descriptors) {
      this.phash = phash;
      this.descriptors = descriptors;
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
    orb = ORB.create();
    orb.setMaxFeatures(Constants.descriptorRows);
    matcher = DescriptorMatcher.create(DescriptorMatcher.BRUTEFORCE_HAMMING);

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
        (call, result) -> {
          switch (call.method) {
            case "generateImageData":
              generateImageData(call, result);
              break;
            case "loadPaintingsData":
              loadPaintingsData(call, result);
              break;
            case "detectPainting":
              detectPainting(call, result);
              break;
            default:
              result.notImplemented();
          }
        });
  }

  private void detectPainting(MethodCall call, MethodChannel.Result result) {
    HashMap args = (HashMap) call.arguments;
    byte[] bytes = (byte[]) args.get("bytes");
    int width = (int) args.get("width");
    int height = (int) args.get("height");

    Mat imgMat = new Mat(height, width, Constants.imageType);
    imgMat.put(0, 0, bytes);

    ImgDataMat imgData = generateImageDataMat(imgMat);

    List<Pair<String, Double>> distancesPhash = new ArrayList<>();
    List<Pair<String, Integer>> matchedKeypoints = new ArrayList<>();
    double phashDiff;

    for (PaintingData paintingData : paintingDataList.values()) {
      phashDiff = pHashClass.compare(paintingData.phash, imgData.phash);
      distancesPhash.add(new Pair<>(paintingData.id, phashDiff));
    }

    Collections.sort(distancesPhash, (o1, o2) ->
        o1.second.compareTo(o2.second)
    );

    int sizePhashes = distancesPhash.size();
    for (int i = 0; i < sizePhashes && i < Constants.keypointCheckListSize; i++) {
      PaintingData paintingData = paintingDataList.get(distancesPhash.get(i).first);

      List<MatOfDMatch> knnMatches = new ArrayList<>();
      matcher.knnMatch(paintingData.keypointDescriptors, imgData.descriptors, knnMatches, 2);
      int goodMatches = 0;
      for (MatOfDMatch match : knnMatches) {
        DMatch[] l = match.toArray();
        if (l[0].distance < 0.7 * l[1].distance) {
          goodMatches++;
        }
      }

      matchedKeypoints.add(new Pair<>(paintingData.id, goodMatches));
    }

    Collections.sort(matchedKeypoints, (o1, o2) ->
        o2.second.compareTo(o1.second)
    );

    print("======== Top 5 results ========");
    print(matchedKeypoints.subList(0, 5).toString());
    result.success(matchedKeypoints.get(0).first);
  }

  private void loadPaintingsData(MethodCall call, MethodChannel.Result result) {
    paintingDataList = new HashMap<>();

    HashMap args = (HashMap) call.arguments;
    List<Map<String, String>> paintingsData = (List<Map<String, String>>) args.get("data");

    for (Map<String, String> paintingData : paintingsData) {
      String id = paintingData.get("id");
      String phashString = paintingData.get("phash");
      String descriptorsString = paintingData.get("descriptors");

      PaintingData p = new PaintingData(id, phashString, descriptorsString);
      paintingDataList.put(id, p);
    }

    print("Loaded " + paintingDataList.size() + " data objects.");

    result.success(true);
  }

  private ImgDataMat generateImageDataMat(Mat imgMat) {
    // Compute pHash
    Mat phashMat = new Mat();
    pHashClass.compute(imgMat, phashMat);

    // Compute keypoints
    MatOfKeyPoint keypoints = new MatOfKeyPoint();
    Mat descriptors = new Mat();
    orb.detectAndCompute(imgMat, new Mat(), keypoints, descriptors);

    return new ImgDataMat(phashMat, descriptors);
  }

  private ImgDataString generateImageDataString(Mat imgMat) {
    ImgDataMat imgDataMat = generateImageDataMat(imgMat);

    // Convert from Mat to base 64 strings
    byte[] phashArray = new byte[Constants.phashRows * Constants.phashCols];
    byte[] descriptorsArray = new byte[Constants.descriptorRows * Constants.descriptorCols];

    imgDataMat.phash.get(0, 0, phashArray);
    imgDataMat.descriptors.get(0, 0, descriptorsArray);

    String phashBase64 = SerializationUtils.toBase64String(phashArray);
    String keypointDescriptorsBase64 = SerializationUtils.toBase64String(descriptorsArray);

    return new ImgDataString(phashBase64, keypointDescriptorsBase64);
  }

  private void generateImageData(MethodCall call, MethodChannel.Result result) {
    HashMap args = (HashMap) call.arguments;
    List<Map<String, String>> paintings = (List<Map<String, String>>) args.get("paintings");

    for (Map<String, String> painting : paintings) {
      String imagePath = painting.get("imagePath");
      String appDir = PathUtils.getDataDirectory(getApplicationContext());

      Mat imgMat = Imgcodecs.imread(appDir + "/" + imagePath);
      Imgproc.cvtColor(imgMat, imgMat, Imgproc.COLOR_BGR2RGB);

      ImgDataString imgDataString = generateImageDataString(imgMat);
      painting.put("phash", imgDataString.phash);
      painting.put("descriptors", imgDataString.descriptors);
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
