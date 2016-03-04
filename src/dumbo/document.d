module dumbo.document;

import std.experimental.allocator;
import std.conv : to;
import std.string : toStringz;
import dumbo.capi;
import dumbo.node;

extern(C) private
void *dumbo_alloc(void *udata, size_t size) {
    return cast(void *)(cast(Document)udata).alloc.makeArray!ubyte(size);
}

extern(C) private
void dumbo_free(void *udata, void *ptr) {
    (cast(Document)udata).alloc.dispose(ptr);
}

class Document {
    package IAllocator alloc;

    private GumboOptions opts;
    private const GumboOutput *output;
    private immutable char *_keep_ref;

    const string name;
    const string public_identifier;
    const string system_identifier;

    Element root;

    this(string buffer, IAllocator allocator = theAllocator) {
        alloc = allocator;

        opts.userdata = cast(void *)this;
        opts.allocator = &dumbo_alloc;
        opts.deallocator = &dumbo_free;
        _keep_ref = buffer.toStringz;

        output = gumbo_parse_with_options(&opts, _keep_ref, buffer.length);
        name = to!string(output.document.v.document.name);
        public_identifier = to!string(output.document.v.document.public_identifier);
        system_identifier = to!string(output.document.v.document.system_identifier);
        root = new Element(output.root);
    }
}
