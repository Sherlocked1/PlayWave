xcodebuild archive -scheme PlayWave -sdk iphonesimulator -archivePath ~/Desktop/PlayWave-iphonesimulator.xcarchive
xcodebuild archive -scheme PlayWave -sdk iphoneos -archivePath ~/Desktop/PlayWave-iphoneos.xcarchive

xcodebuild -create-xcframework -framework ~/Desktop/PlayWave-iphonesimulator.xcarchive/Products/Library/Frameworks/PlayWave.framework \
-framework ~/Desktop/PlayWave-iphoneos.xcarchive/Products/Library/Frameworks/PlayWave.framework \
-output ~/Desktop/PlayerWave.xcframework