package MooseX::Role::Searchable;
use Moose::Role;

requires 'pack';

# ABSTRACT: Add search convenience methods to a class.

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

When used in conjuntion with L<MooseX::Meta::Attribute::Searchable>, this role
can create HashRefs containing all the data necessary to index an object in
a search index.

B<NOTE:> This role expects that it's consuming class will have a C<pack>
method that will return a HashRef, like the one provided by L<MooseX::Storage>.

=method get_searchable_hashref

Returns a hashref with values for all of the search field names that were
specified on the various attributes with the Searchable trait.

=cut

sub get_searchable_hashref {
    my ($self) = @_;

    my $meta = $self->meta;

    # Get the hashref that was so lovingly enabled with MX::Storage
    my $href = $self->pack;
    my $ret = ();

    for my $attr ($meta->get_all_attributes) {
        my $name = $attr->name;
        next unless $href->{$name};

        my $field_name = $name;

        if($attr->does('MooseX::Meta::Attribute::Searchable')) {
            # Either snag the names or use the attribute's name
            my $names = $attr->has_search_field_names ? $attr->search_field_names : [ $name ];
            foreach my $fname (@{ $names }) {
                $ret->{$fname} = $href->{$name};
            }
        }

    }

    return $ret;
}

no Moose::Role;

1;