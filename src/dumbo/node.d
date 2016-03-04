module dumbo.node;

import std.conv : to;
import std.typecons;
import dumbo.capi;
import dumbo.attribute;

class Node {
    Nullable!Node parent;
    const GumboNode * c_node;

    this(const GumboNode *internal_node) {
        parent = null;
        c_node = internal_node;
    }

    static Node fromCApi(const GumboNode *n) {
        if (n.type == GumboNodeType.GUMBO_NODE_ELEMENT)
            return new Element(n);
        return new TextNode(n);
    }
}

class Element : Node {
    const string tag;

    Attribute[] attrs;

    this(const GumboNode *internal_node) {
        super(internal_node);

        tag = to!string(gumbo_normalized_tagname(internal_node.v.element.tag));

        for (size_t i = 0; i < internal_node.v.element.attributes.length; i++)
            attrs ~= new Attribute(cast(const GumboAttribute *)internal_node.v.element.attributes.data[i]);
    }
}

class TextNode : Node {
    this(const GumboNode *internal_node) {
        super(internal_node);
    }
}

