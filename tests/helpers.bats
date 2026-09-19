#!/usr/bin/env bats
# tests/helpers.bats - pure helpers in lib/core.sh and lib/installer.sh.

load 'test_helper'

setup() {
    load_libs
}

# --- domain_to_basedn -------------------------------------------------------

@test "domain_to_basedn: converts a two-label domain" {
    [ "$(domain_to_basedn example.com)" = "dc=example,dc=com" ]
}

@test "domain_to_basedn: converts a multi-label domain" {
    [ "$(domain_to_basedn ad.corp.example.com)" = "dc=ad,dc=corp,dc=example,dc=com" ]
}

@test "domain_to_basedn: a single label has one dc component" {
    [ "$(domain_to_basedn local)" = "dc=local" ]
}

# --- resolve_command --------------------------------------------------------

@test "resolve_command: returns the path of the first available candidate" {
    run resolve_command definitely-not-here bash
    [ "$status" -eq 0 ]
    [[ "$output" == */bash ]]
}

@test "resolve_command: fails when no candidate exists" {
    run resolve_command __nope__ __nada__
    [ "$status" -ne 0 ]
}
