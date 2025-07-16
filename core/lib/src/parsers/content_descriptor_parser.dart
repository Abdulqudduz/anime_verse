import 'package:core/src/models/content_descriptor.dart';
import 'package:core/src/networking/image_url_rewriter.dart';
import 'package:core/src/utils/xml_utils.dart';
import 'package:kt_dart/collection.dart';
import 'package:xml/xml.dart';

class ContentDescriptorParser {
  static KtList<ContentDescriptor> parse(Iterable<XmlElement> roots) {
    var contentDescriptors =
        listFrom(roots).first().findElements('ContentDescriptor');
    return listFrom(contentDescriptors).map((element) {
      return ContentDescriptor(
        name: tagContentsOrNull(element, 'Name') ?? 'Not found it null',
        imageUrl: rewriteImageUrl(tagContentsOrNull(element, 'ImageURL')) ??
            'Not found it null',
      );
    });
  }
}
