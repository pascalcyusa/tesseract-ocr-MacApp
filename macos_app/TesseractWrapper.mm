#import "TesseractWrapper.h"
#include <tesseract/baseapi.h>
#include <leptonica/allheaders.h>
#include <iostream>

@implementation TesseractWrapper {
    tesseract::TessBaseAPI *_tess;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _tess = new tesseract::TessBaseAPI();

        // Attempt to initialize with English
        // Order of preference:
        // 1. App Bundle Resources (if user bundled traineddata)
        // 2. Homebrew Apple Silicon path
        // 3. Homebrew Intel path
        // 4. Default system path (uses TESSDATA_PREFIX env var if set)

        const char *lang = "eng";
        int res = -1;

        // 1. Bundle: Check if 'tessdata' folder exists in resources
        NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
        if (resourcePath) {
            NSString *tessDataPath = [resourcePath stringByAppendingPathComponent:@"tessdata"];
            BOOL isDir;
            if ([[NSFileManager defaultManager] fileExistsAtPath:tessDataPath isDirectory:&isDir] && isDir) {
                // Pass the parent directory (resourcePath) because Init looks for 'tessdata' inside it.
                res = _tess->Init([resourcePath UTF8String], lang);
            }
        }

        // 2. Homebrew Apple Silicon
        if (res != 0) {
            // Check if directory exists to avoid unnecessary error logs from Tesseract
            if ([[NSFileManager defaultManager] fileExistsAtPath:@"/opt/homebrew/share/tessdata"]) {
                res = _tess->Init("/opt/homebrew/share/", lang);
            }
        }

        // 3. Homebrew Intel / MacPorts
        if (res != 0) {
             if ([[NSFileManager defaultManager] fileExistsAtPath:@"/usr/local/share/tessdata"]) {
                res = _tess->Init("/usr/local/share/", lang);
            }
        }

        // 4. Default / Fallback
        if (res != 0) {
            res = _tess->Init(NULL, lang);
        }

        if (res != 0) {
            NSLog(@"[TesseractWrapper] Failed to initialize Tesseract with language '%s'. Ensure traineddata is available in /opt/homebrew/share/tessdata or /usr/local/share/tessdata.", lang);
            delete _tess;
            _tess = nullptr;
            return nil;
        }

        // Set page segmentation mode to auto
        _tess->SetPageSegMode(tesseract::PSM_AUTO);
    }
    return self;
}

- (void)dealloc {
    if (_tess) {
        _tess->End();
        delete _tess;
    }
}

- (NSString *)recognizeImage:(NSImage *)image {
    if (!_tess) return nil;

    // Convert NSImage to PNG data which Leptonica can read safely from memory
    NSData *tiffData = [image TIFFRepresentation];
    if (!tiffData) {
        NSLog(@"[TesseractWrapper] Failed to get TIFF representation.");
        return nil;
    }

    NSBitmapImageRep *bitmap = [NSBitmapImageRep imageRepWithData:tiffData];
    if (!bitmap) {
        NSLog(@"[TesseractWrapper] Failed to create bitmap rep.");
        return nil;
    }

    NSData *pngData = [bitmap representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
    if (!pngData) {
        NSLog(@"[TesseractWrapper] Failed to get PNG representation.");
        return nil;
    }

    // Use Leptonica to read the image from memory
    Pix *pix = pixReadMem((const l_uint8 *)[pngData bytes], [pngData length]);
    if (!pix) {
        NSLog(@"[TesseractWrapper] Failed to create Pix from data.");
        return nil;
    }

    _tess->SetImage(pix);

    char *text = _tess->GetUTF8Text();
    NSString *result = nil;
    if (text) {
        result = [NSString stringWithUTF8String:text];
        delete [] text;
    }

    pixDestroy(&pix);

    return result;
}

@end
