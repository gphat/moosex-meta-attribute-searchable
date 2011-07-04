package MooseX::Meta::Attribute::Searchable;
use Moose::Role;

# ABSTRACT: Make an attribute searchable for an external index.

=head1 SYNOPSIS

    package MyObject;
    use Moose;

    with 'MooseX::Role::Searchable';

    has 'name' => (
        is => 'rw',
        isa => 'Str',
        traits => [ qw(MooseX::Meta::Attribute::Searchable) ],
        search_field_names => [ qw(name name_ngram) ],
    );

    1;

    # Later...

    my $obj = MyObject->new(name => 'user');
    my $href = $obj->get_searchable_hashref;
    $searchengine->index(id => $obj->id, $href);

=head1 DESCRIPTION

MooseX::Meta::Attribute::Searchable and L<MooseX::Role::Searchable> combine to
to mark attributes for indexing, naming any alternative names it may use, and
to create a datastructure suitable for passing to an external indexer.

By applying the MooseX::Meta::Attribute::Searchable trait to an attribute, you
are signaling that the attribute will be included in the index.

If you specify C<search_field_names> then copies of the attribute will be
included in your result for populating other fields.

=begin :prelude

=head1 MOTIVATION

In many of my projects an external search index such as
L<Solr|http://lucene.apache.org/solr/> or
L<ElasticSearch|http://www.elasticsearch.org/> is used.  Many times the things
I am indexing are Moose objects.  This pair of roles makes it easy to mark
which attributes should be included in the indexed document and optionally
gives the ability to rename or specificy multiple names for an attribute.

The optional C<search_field_names> is useful when you have a single value that
you'd like to index in multiple ways.  An example of this is a field that you
might want searchable in both full-text and autocomplete situations.  In Solr
I've used a "name" and "name_ngram" field in the schema, where the latter used
an EdgeNGram filter for auto-complete.

=end :prelude

=attr search_field_names

The field name(s) in the search index.  Even if you only use one name, this
must be an ArrayRef.

=method has_search_field_names

Returns true if this attribute has any field names specified.

=cut

has 'search_field_names' => (
    is => 'ro',
    isa => 'ArrayRef[Str]',
    predicate => 'has_search_field_names',
);

no Moose::Role;
1;
