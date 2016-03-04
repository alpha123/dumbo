divert(-1)
define(`enumify', `patsubst(translit(`$1',`a-z-',`A-Z_'),`^.+$',`$2_\&,')')
define(`include_enum', `enumify(include(`$1'), `$2')')
divert

module dumbo.capi;

extern(C) {

struct GumboSourcePosition {
    uint line;
    uint column;
    uint offset;
}

extern __gshared const GumboSourcePosition kGumboEmptySourcePosition;

struct GumboStringPiece {
    const char *data;
    size_t length;
}

extern __gshared const GumboStringPiece kGumboEmptyString;

bool gumbo_string_equals(const GumboStringPiece *str1, const GumboStringPiece *str2);

bool gumbo_string_equals_ignore_case(const GumboStringPiece *str1, const GumboStringPiece *str2);

struct GumboVector {
    void **data;
    uint length;
    uint capacity;
}

extern __gshared const GumboVector kGumboEmptyVector;

int gumbo_vector_index_of(GumboVector *vector, const void *element);

enum GumboTag {
include_enum(`tags.in', `GUMBO_TAG')
}

char *gumbo_normalized_tagname(GumboTag tag);

void gumbo_tag_from_original_text(GumboStringPiece *text);

char *gumbo_normalize_svg_tagname(const GumboStringPiece *tagname);

GumboTag gumbo_tag_enum(const char *tagname);
GumboTag gumbo_tagn_enum(const char *tagname, uint length);

enum GumboAttributeNamespaceEnum {
include_enum(`attr_namespaces.in', `GUMBO_ATTR_NAMESPACE')
}

struct GumboAttribute {
    GumboAttributeNamespaceEnum attr_namespace;

    const char *name;
    GumboStringPiece original_name;

    const char *value;
    GumboStringPiece original_value;

    GumboSourcePosition name_start;
    GumboSourcePosition name_end;

    GumboSourcePosition value_start;
    GumboSourcePosition value_end;
}

GumboAttribute *gumbo_get_attribute(const GumboVector *attrs, const char *name);

enum GumboNodeType {
include_enum(`node_types.in', `GUMBO_NODE')
}

enum GumboQuirksModeEnum {
include_enum(`quirks.in', `GUMBO_DOCTYPE')
}

enum GumboNamespaceEnum {
include_enum(`namespaces.in', `GUMBO_NAMESPACE')
}

enum GumboParseFlags {
include_enum(`parse_flags.in', `GUMBO_INSERTION')
}

struct GumboDocument {
    GumboVector children;

    bool has_doctype;

    const char *name;
    const char *public_identifier;
    const char *system_identifier;

    GumboQuirksModeEnum doc_type_quirks_mode;
}

struct GumboText {
    const char *text;
    GumboStringPiece original_text;

    GumboSourcePosition start_pos;
}

struct GumboElement {
    GumboVector children;

    GumboTag tag;
    GumboNamespaceEnum tag_namespace;
    GumboStringPiece original_tag;
    GumboStringPiece original_end_tag;

    GumboSourcePosition start_pos;
    GumboSourcePosition end_pos;

    GumboVector attributes;
}

struct GumboNode {
    GumboNodeType type;

    GumboNode *parent;

    size_t index_within_parent;

    GumboParseFlags parse_flags;

    private union _Contents {
	GumboDocument document;
	GumboElement element;
	GumboText text;
    }
    _Contents v;
}

alias GumboAllocatorFunction = void *function(void *userdata, size_t size);
alias GumboDeallocatorFunction = void function(void *userdata, void *ptr);

struct GumboOptions {
    GumboAllocatorFunction allocator;
    GumboDeallocatorFunction deallocator;

    void *userdata;

    int tab_stop;

    bool stop_on_first_error;

    int max_errors;

    GumboTag fragment_context;

    GumboNamespaceEnum fragment_namespace;
}

extern __gshared const GumboOptions kGumboDefaultOptions;

struct GumboOutput {
    GumboNode *document;

    GumboNode *root;

    GumboVector errors;
}

GumboOutput *gumbo_parse(const char *buffer);

GumboOutput *gumbo_parse_with_options(const GumboOptions *options, const char *buffer, size_t buffer_length);

void gumbo_destroy_output(const GumboOptions *options, GumboOutput *output);

}
