package com.openmg.open_museum_guide;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;

import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;

import io.flutter.plugin.common.MethodChannel;

import android.util.Log;

import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.util.HashMap;

import org.opencv.android.Utils;
import org.opencv.core.CvType;
import org.opencv.core.Mat;
import org.opencv.img_hash.Img_hash;
import org.opencv.img_hash.PHash;
import org.opencv.imgproc.Imgproc;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "demo.openmuseumguide.com/opencv";
  private PHash pHashClass;

  static {
    System.loadLibrary("opencv_java3");
  }

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    pHashClass = PHash.create();

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
        (call, result) -> {
          if (call.method.equals("runEdgeDetectionOnImage")) {
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
          } else {
            result.notImplemented();
          }
        });
  }
}
