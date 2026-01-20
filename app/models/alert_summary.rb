# frozen_string_literal: true
class AlertSummary < ApplicationRecord
  self.table_name = :alert_summary

  # Field mapping for data with different field names
  FIELD_MAPPING = {
    'alert_type' => 'alert_summary_type',
    'title' => 'title',
    'body' => 'body',
    'active' => 'active'
  }.freeze

  # Map external data fields to model attributes
  # @param data [Hash] The data hash with external field names
  # @return [Hash] Hash with model attribute names
  def self.map_fields(data)
    data.transform_keys do |key|
      FIELD_MAPPING[key.to_s]
    end.compact.except(nil)
  end

  # Create a new record from mapped data
  # @param data [Hash] The data hash with external field names
  # @return [AlertSummary] The created record
  def self.create_from_mapped_data(data)
    mapped_data = map_fields(data)
    create(mapped_data)
  end

  # Create a new record from mapped data (with bang)
  # @param data [Hash] The data hash with external field names
  # @return [AlertSummary] The created record
  def self.create_from_mapped_data!(data)
    mapped_data = map_fields(data)
    create!(mapped_data)
  end

  # Update record with mapped data
  # @param data [Hash] The data hash with external field names
  # @return [Boolean] true if update succeeded
  def update_from_mapped_data(data)
    mapped_data = self.class.map_fields(data)
    update(mapped_data)
  end

  # Update record with mapped data (with bang)
  # @param data [Hash] The data hash with external field names
  # @return [Boolean] true if update succeeded
  def update_from_mapped_data!(data)
    mapped_data = self.class.map_fields(data)
    update!(mapped_data)
  end
end

