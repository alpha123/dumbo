module dumbo.attribute;

import std.conv : to;
import dumbo.capi;

class Attribute {
    enum Namespace { None, XLink, XML, XMLNS }

    const Namespace namespace;

    const string name;
    const string value;

    const GumboAttribute *c_attr;

    this(const GumboAttribute *internal_attr) {
        c_attr = internal_attr;
        if (internal_attr.attr_namespace == GumboAttributeNamespaceEnum.GUMBO_ATTR_NAMESPACE_XLINK)
            namespace = Namespace.XLink;
        else if (internal_attr.attr_namespace == GumboAttributeNamespaceEnum.GUMBO_ATTR_NAMESPACE_XML)
            namespace = Namespace.XML;
        else if (internal_attr.attr_namespace == GumboAttributeNamespaceEnum.GUMBO_ATTR_NAMESPACE_XMLNS)
            namespace = Namespace.XMLNS;
        else
            namespace = Namespace.None;

        name = to!string(internal_attr.name);
        value = to!string(internal_attr.value);
    }
}
