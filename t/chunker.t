use strict;
use warnings;
use Test::More;
use Lic::Scanner::Chunker;


subtest 'Test chunker with empty input' => sub {
    my @result = Lic::Scanner::Chunker::chunker('');
    is_deeply(\@result, [], 'Empty input should return an empty list');
};

subtest 'Test chunker with simple input' => sub {
    my @result = Lic::Scanner::Chunker::chunker('feature:entitlement=value');
    is_deeply(\@result, [['FEATURE', 'value']], 'Simple input should return processed key-value pair');
};

subtest 'Test chunker with complex input' => sub {
    my @result = Lic::Scanner::Chunker::chunker('feature:entitlement=value other:entitlement=another');
    is_deeply(\@result, [['FEATURE', 'value'], ['OTHER', 'another']], 'Complex input should return multiple processed key-value pairs');
};

subtest 'Test chunker with mixed input' => sub {
    my @result = Lic::Scanner::Chunker::chunker('feature:entitlement=value "quoted string" {bracketed}');
    is_deeply(\@result, [['FEATURE', 'value'], '"quoted string"', '{bracketed}'], 'Mixed input should return processed key-value pair and other elements');
};

subtest 'Test _processKV' => sub {
    my $array_ref;

    # Test case 1: Simple key-value pair
    $array_ref = [ 'key', '=', 'value' ];
    Lic::Scanner::Chunker::_processKV($array_ref);
    is_deeply($array_ref, [ [ 'KEY', 'value' ] ], 'Simple key-value pair');

    # Test case 2: Multiple key-value pairs
    $array_ref = [ 'key1', '=', 'value1', 'key2', '=', 'value2' ];
    Lic::Scanner::Chunker::_processKV($array_ref);
    is_deeply($array_ref, [ [ 'KEY1', 'value1' ], [ 'KEY2', 'value2' ] ], 'Multiple key-value pairs');

    # Test case 3: No key-value pairs
    $array_ref = [ 'no', 'key', 'value' ];
    Lic::Scanner::Chunker::_processKV($array_ref);
    is_deeply($array_ref, [ 'no', 'key', 'value' ], 'No key-value pairs');

    # Test case 2: Multiple key-value pairs with non-key-value 
    $array_ref = [ 'key1', '=', 'value1', 'only one', 'key2', '=', 'value2' ];
    Lic::Scanner::Chunker::_processKV($array_ref);
    is_deeply($array_ref, [ [ 'KEY1', 'value1' ],'only one', [ 'KEY2', 'value2' ] ], 'Multiple key-value pairs');
};

done_testing();