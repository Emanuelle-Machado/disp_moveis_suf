import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  // Mapa de traduções
  static const Map<String, Map<String, String>> _localizedValues = {
    'pt_BR': {
      'appTitle': 'Gerenciador de Máquinas',
      'machines': 'Máquinas',
      'types': 'Tipos',
      'brands': 'Marcas',
      'newMachine': 'Nova Máquina',
      'editMachine': 'Editar Máquina',
      'description': 'Descrição',
      'save': 'Salvar',
      'noInternet': 'Sem conexão com a internet',
      'dataUpdated': 'Dados da API atualizados',
      'cancel': 'Cancelar',
      'delete': 'Excluir',
      'required': 'Obrigatório',
    },
    'en': {
      'appTitle': 'Machine Manager',
      'machines': 'Machines',
      'types': 'Types',
      'brands': 'Brands',
      'newMachine': 'New Machine',
      'editMachine': 'Edit Machine',
      'description': 'Description',
      'save': 'Save',
      'noInternet': 'No internet connection',
      'dataUpdated': 'API data updated',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'required': 'Required',
    },
  };

  // Acessar traduções
  String translate(String key) {
    return _localizedValues[locale.toString()]?[key] ?? key;
  }

  // Propriedades para traduções
  String get appTitle => translate('appTitle');
  String get machines => translate('machines');
  String get types => translate('types');
  String get brands => translate('brands');
  String get newMachine => translate('newMachine');
  String get editMachine => translate('editMachine');
  String get description => translate('description');
  String get save => translate('save');
  String get noInternet => translate('noInternet');
  String get dataUpdated => translate('dataUpdated');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get required => translate('required');

  // Acesso via context
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // Delegate para Flutter
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['pt_BR', 'en'].contains(locale.toString());
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}