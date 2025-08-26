/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// NOTE: This file is generated and may not follow lint rules defined in your app
// Generated files can be excluded from analysis in analysis_options.yaml
// For more info, see: https://dart.dev/guides/language/analysis-options#excluding-code-from-analysis

// ignore_for_file: public_member_api_docs, annotate_overrides, dead_code, dead_codepublic_member_api_docs, depend_on_referenced_packages, file_names, library_private_types_in_public_api, no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, null_check_on_nullable_type_parameter, override_on_non_overriding_member, prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_if_null_operators, prefer_interpolation_to_compose_strings, slash_for_doc_comments, sort_child_properties_last, unnecessary_const, unnecessary_constructor_name, unnecessary_late, unnecessary_new, unnecessary_null_aware_assignments, unnecessary_nullable_for_final_variable_declarations, unnecessary_string_interpolations, use_build_context_synchronously

import 'ModelProvider.dart';
import 'package:amplify_core/amplify_core.dart' as amplify_core;


/** This is an auto generated class representing the RecipeIngredient type in your schema. */
class RecipeIngredient {
  final String? _name;
  final String? _offId;
  final double? _quantity;
  final String? _unit;

  String get name {
    try {
      return _name!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get offId {
    try {
      return _offId!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  double get quantity {
    try {
      return _quantity!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  String get unit {
    try {
      return _unit!;
    } catch(e) {
      throw amplify_core.AmplifyCodeGenModelException(
          amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastExceptionMessage,
          recoverySuggestion:
            amplify_core.AmplifyExceptionMessages.codeGenRequiredFieldForceCastRecoverySuggestion,
          underlyingException: e.toString()
          );
    }
  }
  
  const RecipeIngredient._internal({required name, required offId, required quantity, required unit}): _name = name, _offId = offId, _quantity = quantity, _unit = unit;
  
  factory RecipeIngredient({required String name, required String offId, required double quantity, required String unit}) {
    return RecipeIngredient._internal(
      name: name,
      offId: offId,
      quantity: quantity,
      unit: unit);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RecipeIngredient &&
      _name == other._name &&
      _offId == other._offId &&
      _quantity == other._quantity &&
      _unit == other._unit;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("RecipeIngredient {");
    buffer.write("name=" + "$_name" + ", ");
    buffer.write("offId=" + "$_offId" + ", ");
    buffer.write("quantity=" + (_quantity != null ? _quantity!.toString() : "null") + ", ");
    buffer.write("unit=" + "$_unit");
    buffer.write("}");
    
    return buffer.toString();
  }
  
  RecipeIngredient copyWith({String? name, String? offId, double? quantity, String? unit}) {
    return RecipeIngredient._internal(
      name: name ?? this.name,
      offId: offId ?? this.offId,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit);
  }
  
  RecipeIngredient copyWithModelFieldValues({
    ModelFieldValue<String>? name,
    ModelFieldValue<String>? offId,
    ModelFieldValue<double>? quantity,
    ModelFieldValue<String>? unit
  }) {
    return RecipeIngredient._internal(
      name: name == null ? this.name : name.value,
      offId: offId == null ? this.offId : offId.value,
      quantity: quantity == null ? this.quantity : quantity.value,
      unit: unit == null ? this.unit : unit.value
    );
  }
  
  RecipeIngredient.fromJson(Map<String, dynamic> json)  
    : _name = json['name'],
      _offId = json['offId'],
      _quantity = (json['quantity'] as num?)?.toDouble(),
      _unit = json['unit'];
  
  Map<String, dynamic> toJson() => {
    'name': _name, 'offId': _offId, 'quantity': _quantity, 'unit': _unit
  };
  
  Map<String, Object?> toMap() => {
    'name': _name,
    'offId': _offId,
    'quantity': _quantity,
    'unit': _unit
  };

  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "RecipeIngredient";
    modelSchemaDefinition.pluralName = "RecipeIngredients";
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'name',
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'offId',
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'quantity',
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.double)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.customTypeField(
      fieldName: 'unit',
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
  });
}