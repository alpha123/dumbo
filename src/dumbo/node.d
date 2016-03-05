module dumbo.node;

import std.conv : to;
import std.typecons;
import dumbo.capi;
import dumbo.attribute;

class Node {
    Nullable!Node parent;
    const GumboNode *c_node;

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
    Node[] children;
    Element[] elem_children;

    this(const GumboNode *internal_node) {
        super(internal_node);

        tag = to!string(gumbo_normalized_tagname(internal_node.v.element.tag));

        for (size_t i = 0; i < internal_node.v.element.attributes.length; i++)
            attrs ~= new Attribute(cast(const GumboAttribute *)internal_node.v.element.attributes.data[i]);

        for (size_t i = 0; i < internal_node.v.element.children.length; i++) {
            auto kid = Node.fromCApi(cast(const GumboNode *)internal_node.v.element.children.data[i]);
            kid.parent = this;
            children ~= kid;
            if (kid.c_node.type == GumboNodeType.GUMBO_NODE_ELEMENT)
                elem_children ~= cast(Element)kid;
        }
    }
}

class TextNode : Node {
    const string text;

    this(const GumboNode *internal_node) {
        super(internal_node);

        text = to!string(internal_node.v.text);
    }
}

