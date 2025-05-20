// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(nome) => "Do you want to remove the brand \"${nome}\"?";

  static String m1(descricao) =>
      "Do you want to remove the type \"${descricao}\"?";

  static String m2(descricao) =>
      "Are you sure you want to remove \"${descricao}\"?";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "cadastrar": MessageLookupByLibrary.simpleMessage("Register"),
    "cadastrarMaquina": MessageLookupByLibrary.simpleMessage(
      "Register Machine",
    ),
    "cadastrarMarca": MessageLookupByLibrary.simpleMessage("Register Brand"),
    "cancelar": MessageLookupByLibrary.simpleMessage("Cancel"),
    "confirmarRemocao": MessageLookupByLibrary.simpleMessage("Confirm removal"),
    "descricao": MessageLookupByLibrary.simpleMessage("Description"),
    "desejaRemoverMarca": m0,
    "desejaRemoverTipo": m1,
    "editarMaquina": MessageLookupByLibrary.simpleMessage("Edit Machine"),
    "editarMarca": MessageLookupByLibrary.simpleMessage("Edit Brand"),
    "informeDescricao": MessageLookupByLibrary.simpleMessage(
      "Enter the description",
    ),
    "informeNome": MessageLookupByLibrary.simpleMessage("Enter the name"),
    "maquinas": MessageLookupByLibrary.simpleMessage("Machines"),
    "marcas": MessageLookupByLibrary.simpleMessage("Brands"),
    "nenhumaMarcaCadastrada": MessageLookupByLibrary.simpleMessage(
      "No brands registered.",
    ),
    "nome": MessageLookupByLibrary.simpleMessage("Name"),
    "novaMarca": MessageLookupByLibrary.simpleMessage("New Brand"),
    "remover": MessageLookupByLibrary.simpleMessage("Remove"),
    "removerMaquina": MessageLookupByLibrary.simpleMessage("Remove Machine"),
    "removerMarca": MessageLookupByLibrary.simpleMessage("Remove Brand"),
    "salvar": MessageLookupByLibrary.simpleMessage("Save"),
    "temCertezaRemoverMaquina": m2,
    "tipos": MessageLookupByLibrary.simpleMessage("Types"),
    "tooltipCadastrarMaquina": MessageLookupByLibrary.simpleMessage(
      "Register Machine",
    ),
  };
}
