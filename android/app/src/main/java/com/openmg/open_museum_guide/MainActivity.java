package com.openmg.open_museum_guide;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Matrix;
import android.os.AsyncTask;
import android.os.Bundle;
import android.renderscript.Allocation;
import android.renderscript.Element;
import android.renderscript.RenderScript;
import android.renderscript.ScriptIntrinsicYuvToRGB;
import android.renderscript.Type;
import android.util.Log;
import android.util.Pair;

import org.opencv.android.Utils;
import org.opencv.core.DMatch;
import org.opencv.core.Mat;
import org.opencv.core.MatOfDMatch;
import org.opencv.core.MatOfKeyPoint;
import org.opencv.features2d.DescriptorMatcher;
import org.opencv.features2d.ORB;
import org.opencv.img_hash.PHash;
import org.opencv.imgcodecs.Imgcodecs;
import org.opencv.imgproc.Imgproc;

import java.nio.ByteBuffer;
import java.util.ArrayList;
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
  private static PHash pHashClass;
  private static ORB orb;
  private static DescriptorMatcher matcher;

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
    pHashClass = PHash.create();
    orb = ORB.create();
    orb.setMaxFeatures(Constants.descriptorRows);
    orb.setFastThreshold(10);
    matcher = DescriptorMatcher.create(DescriptorMatcher.BRUTEFORCE_HAMMING);
  }

  private static void print(String str) {
    Log.d("ANDROID", str);
  }

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

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
            case "detectPaintingFrame":
              detectPaintingFrame(call, result);
              break;
            case "unloadPaintingsData":
              unloadPaintingsData(call, result);
              break;
            default:
              result.notImplemented();
          }
        });
  }

  private void unloadPaintingsData(MethodCall call, MethodChannel.Result result) {
    paintingDataList = null;
    print("Unloaded data.");
    result.success(true);
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

  private static ImgDataMat generateImageDataMat(Mat imgMat) {
    // Compute pHash
    Mat phashMat = new Mat();
    pHashClass.compute(imgMat, phashMat);

    // Compute keypoints
    MatOfKeyPoint keypoints = new MatOfKeyPoint();
    Mat descriptors = new Mat();
    orb.detectAndCompute(imgMat, new Mat(), keypoints, descriptors);

    return new ImgDataMat(phashMat, descriptors);
  }

  private static ImgDataString generateImageDataString(Mat imgMat) {
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

  private void detectPainting(MethodCall call, MethodChannel.Result result) {
    new DetectPaintingTask(call, result, paintingDataList).execute();
  }

  private void detectPaintingFrame(MethodCall call, MethodChannel.Result result) {
    HashMap args = (HashMap) call.arguments;
    List<byte[]> bytesList = (ArrayList<byte[]>) args.get("bytes");
    int width = (int) args.get("width");
    int height = (int) args.get("height");
    int x = (int) args.get("x");
    int y = (int) args.get("y");
    int w = (int) args.get("w");
    int h = (int) args.get("h");
    int rotation = 90;

    ByteBuffer Y = ByteBuffer.wrap(bytesList.get(0));
    ByteBuffer U = ByteBuffer.wrap(bytesList.get(1));
    ByteBuffer V = ByteBuffer.wrap(bytesList.get(2));

    int Yb = Y.remaining();
    int Ub = U.remaining();
    int Vb = V.remaining();

    byte[] data = new byte[Yb + Ub + Vb];

    Y.get(data, 0, Yb);
    V.get(data, Yb, Vb);
    U.get(data, Yb + Vb, Ub);

    Bitmap bitmapRaw = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
    Allocation bmData = renderScriptNV21ToRGBA888(
        getApplicationContext(),
        width,
        height,
        data);
    bmData.copyTo(bitmapRaw);

    bitmapRaw = Bitmap.createBitmap(bitmapRaw, x, y, w, h);
    Matrix matrix = new Matrix();
    matrix.postRotate(rotation);
    bitmapRaw = Bitmap.createBitmap(bitmapRaw, 0, 0, bitmapRaw.getWidth(), bitmapRaw.getHeight(), matrix, true);

    Mat imgMat = new Mat();
    Utils.bitmapToMat(bitmapRaw, imgMat);

    new DetectPaintingTask(call, result, paintingDataList, imgMat).execute();
  }

  public Allocation renderScriptNV21ToRGBA888(Context context, int width, int height, byte[] nv21) {
    RenderScript rs = RenderScript.create(context);
    ScriptIntrinsicYuvToRGB yuvToRgbIntrinsic = ScriptIntrinsicYuvToRGB.create(rs, Element.U8_4(rs));

    Type.Builder yuvType = new Type.Builder(rs, Element.U8(rs)).setX(nv21.length);
    Allocation in = Allocation.createTyped(rs, yuvType.create(), Allocation.USAGE_SCRIPT);

    Type.Builder rgbaType = new Type.Builder(rs, Element.RGBA_8888(rs)).setX(width).setY(height);
    Allocation out = Allocation.createTyped(rs, rgbaType.create(), Allocation.USAGE_SCRIPT);

    in.copyFrom(nv21);

    yuvToRgbIntrinsic.setInput(in);
    yuvToRgbIntrinsic.forEach(out);
    return out;
  }

  private void generateImageData(MethodCall call, MethodChannel.Result result) {
    new GenerateImageDataTask(call, result).execute(getApplicationContext());
  }

  private static class DetectPaintingTask extends AsyncTask<Void, Void, String> {
    private MethodChannel.Result result;
    private int width, height;
    private byte[] bytes;
    private Map<String, PaintingData> paintingDataList;
    private Mat imgMat;

    public DetectPaintingTask(MethodCall call, MethodChannel.Result result, Map<String, PaintingData> paintingDataList) {
      this.result = result;
      this.paintingDataList = paintingDataList;

      HashMap args = (HashMap) call.arguments;
      this.bytes = (byte[]) args.get("bytes");
      this.width = (int) args.get("width");
      this.height = (int) args.get("height");
      this.imgMat = new Mat(height, width, Constants.imageType);
      imgMat.put(0, 0, bytes);
    }

    public DetectPaintingTask(MethodCall call, MethodChannel.Result result, Map<String, PaintingData> paintingDataList, Mat imgMat) {
      this.result = result;
      this.paintingDataList = paintingDataList;

      HashMap args = (HashMap) call.arguments;
      this.imgMat = imgMat;
    }

    @Override
    protected String doInBackground(Void... voids) {
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
        if (paintingData == null) continue;

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
      if (matchedKeypoints.get(0).second >= Constants.thresholdKeypoints)
        return matchedKeypoints.get(0).first;
      return null;
    }

    @Override
    protected void onPostExecute(String resultId) {
      result.success(resultId);
    }
  }

  private static class GenerateImageDataTask extends AsyncTask<Context, Void, List<Map<String, String>>> {
    private MethodChannel.Result result;
    private List<Map<String, String>> paintings;

    public GenerateImageDataTask(MethodCall call, MethodChannel.Result result) {
      this.result = result;

      HashMap args = (HashMap) call.arguments;
      this.paintings = (List<Map<String, String>>) args.get("paintings");
    }

    @Override
    protected List<Map<String, String>> doInBackground(Context... contexts) {
      Context context = contexts[0];
      String appDir = PathUtils.getDataDirectory(context);

      for (Map<String, String> painting : paintings) {
        String imagePath = painting.get("imagePath");

        // print(imagePath);

        Mat imgMat = Imgcodecs.imread(appDir + "/" + imagePath);

        if (imgMat.empty()) {
          print("Could not find " + imagePath + ", skipping...");
          continue;
        }

        Imgproc.cvtColor(imgMat, imgMat, Imgproc.COLOR_BGR2RGB);

        ImgDataString imgDataString = generateImageDataString(imgMat);
        painting.put("phash", imgDataString.phash);
        painting.put("descriptors", imgDataString.descriptors);
        painting.remove("imagePath");
      }

      return paintings;
    }

    @Override
    protected void onPostExecute(List<Map<String, String>> pnts) {
      result.success(pnts);
    }
  }
}
