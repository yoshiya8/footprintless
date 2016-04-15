use strict;
use warnings;

package Footprintless::App;

# ABSTRACT: The base application class for fpl
# PODNAME: Footprintless::App

use App::Cmd::Setup -app;
use Footprintless;
use Log::Any;

my $logger = Log::Any->get_logger();

# todo: remove after https://github.com/rjbs/App-Cmd/pull/60
sub new {
    my ($class, $arg) = @_;

    my $arg0 = $0;
    require File::Basename;
    my $base = File::Basename::basename $arg0;

    my $self = bless(
        {
            arg0         => $base,
            full_arg0    => $arg0,
            show_version => $arg->{show_version_cmd} || 0,
        },
        $class);

    $self->{command} = $self->_command($arg);

    return $self;
}

sub _configure_logging {
    my ($self, $level) = @_;
    require Log::Any::Adapter;
    Log::Any::Adapter->set('Stderr', 
        log_level => Log::Any::Adapter::Util::numeric_level($level));
}

sub footprintless {
    my ($self) = @_;

    if (!defined($self->{footprintless})) {
        $self->{footprintless} = Footprintless->new();
    }

    return $self->{footprintless};
}

sub get_command {
    my ($self, @args) = @_;
    my ($command, $opt, @rest) = $self->App::Cmd::get_command(@args);

    if ($opt->{log}) {
        $self->_configure_logging(delete($opt->{log}));
    }

    return ($command, $opt, @rest);
}

sub global_opt_spec {
    my ($self) = @_;
    return (
        ["log=s", "sets the log level",],
        $self->App::Cmd::global_opt_spec()
    );
}

sub footprintless_plugin_search_paths {
    my ($self) = @_;
print("REMOVE ME: WTF?\n");

    unless ($self->{plugin_search_paths}) {
        my @paths = ();
        foreach my $plugin ($self->footprintless()->plugins()) {
            push(@paths, $plugin->command_packages());
        }
        $self->{plugin_search_paths} = \@paths;
    }

    return @{$self->{plugin_search_paths}};
}

sub plugin_search_path {
    my ($self) = @_;

    my $search_path = [
        'Footprintless::App::Command',
        $self->footprintless_plugin_search_paths()
    ];

    return $search_path;
}

1;
__END__
=method footprintless()

Returns the instance of C<Footprintless> for this instance of the app.

=for Pod::Coverage get_command global_opt_spec footprintless_plugin_search_paths plugin_search_path

=head1 SEE ALSO

App::Cmd
Footprintless
