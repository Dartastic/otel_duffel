// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_duffel_suppression.dart';

const _tracerName = 'dartastic_otel_libs_duffel';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class DuffelResult {
  const DuffelResult({
    this.environment,
    this.offerRequestId,
    this.offerId,
    this.orderId,
    this.bookingReference,
    this.origin,
    this.destination,
    this.passengerCount,
    this.cabinClass,
    this.sliceCount,
    this.offerCount,
    this.totalAmountCents,
    this.totalCurrency,
    this.airline,
    this.ancillaryKind,
    this.ancillaryAmountCents,
    this.paymentMethod,
    this.orderStatus,
    this.paymentStatus,
    this.changeRequestId,
    this.changeOfferCount,
    this.refundAmountCents,
    this.errorType,
    this.errorTitle,
    this.statusCode,
  });

  /// `sandbox` / `live`.
  final String? environment;

  /// `orq_xxx` offer request id.
  final String? offerRequestId;

  /// `off_xxx` offer id selected.
  final String? offerId;

  /// `ord_xxx` order id.
  final String? orderId;

  /// 6-char airline booking reference (PNR).
  final String? bookingReference;

  final String? origin;
  final String? destination;

  final int? passengerCount;

  /// `economy`, `premium_economy`, `business`, `first`.
  final String? cabinClass;

  final int? sliceCount;
  final int? offerCount;

  final int? totalAmountCents;
  final String? totalCurrency;

  /// IATA airline code on the marketing carrier.
  final String? airline;

  /// `seat`, `bag`, `cancel_for_any_reason`, `extra_legroom`, `priority`,
  /// `meal`, `lounge`.
  final String? ancillaryKind;

  final int? ancillaryAmountCents;

  /// `balance`, `arc_bsp_cash`, `card`.
  final String? paymentMethod;

  /// `created`, `partially_paid`, `paid`, `cancelled`, `failed`.
  final String? orderStatus;

  /// `succeeded`, `failed`, `pending`.
  final String? paymentStatus;

  /// `ocr_xxx` order change request id.
  final String? changeRequestId;
  final int? changeOfferCount;

  final int? refundAmountCents;

  /// Duffel error type
  /// (`validation_error`, `invalid_request_error`, `authentication_error`,
  /// `airline_error`, `rate_limit_error`, `api_error`).
  final String? errorType;
  final String? errorTitle;
  final int? statusCode;
}

class DuffelCallResult<T> {
  const DuffelCallResult({required this.value, this.result});
  final T value;
  final DuffelResult? result;
}

/// Wraps a Duffel API call in a CLIENT span. [operation] is one of
/// `offerRequests.create`, `offerRequests.get`, `offerRequests.list`,
/// `offers.list`, `offers.get`, `offers.update`,
/// `orders.create`, `orders.get`, `orders.list`, `orders.update`,
/// `orderCancellations.create`, `orderCancellations.confirm`,
/// `orderChangeRequests.create`, `orderChangeRequests.get`,
/// `orderChangeOffers.list`, `orderChangeOffers.get`,
/// `orderChanges.create`, `orderChanges.confirm`,
/// `payments.create`, `payments.list`, `seatMaps.get`,
/// `partialOfferRequests.create`, `airlines.list`,
/// `aircraft.list`, `cities.list`, `airports.list`,
/// `placeSuggestions.list`, `webhooks.parse`.
Future<T> tracedDuffel<T>({
  required String operation,
  required Future<DuffelCallResult<T>> Function() invoke,
}) async {
  if (duffelInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'duffel',
    'rpc.method': operation,
    'duffel.operation': operation,
  };

  final span = _tracer().startSpan(
    'duffel $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.environment != null) {
        extras.add(OTel.attributeString(
          'duffel.environment',
          res.environment!,
        ));
      }
      if (res.offerRequestId != null) {
        extras.add(OTel.attributeString(
          'duffel.offer_request.id',
          res.offerRequestId!,
        ));
      }
      if (res.offerId != null) {
        extras.add(OTel.attributeString('duffel.offer.id', res.offerId!));
      }
      if (res.orderId != null) {
        extras.add(OTel.attributeString('duffel.order.id', res.orderId!));
      }
      if (res.bookingReference != null) {
        extras.add(OTel.attributeString(
          'duffel.order.booking_reference',
          res.bookingReference!,
        ));
      }
      if (res.origin != null) {
        extras.add(OTel.attributeString('duffel.origin', res.origin!));
      }
      if (res.destination != null) {
        extras.add(OTel.attributeString(
          'duffel.destination',
          res.destination!,
        ));
      }
      if (res.passengerCount != null) {
        extras.add(OTel.attributeInt(
          'duffel.passenger.count',
          res.passengerCount!,
        ));
      }
      if (res.cabinClass != null) {
        extras.add(OTel.attributeString(
          'duffel.cabin_class',
          res.cabinClass!,
        ));
      }
      if (res.sliceCount != null) {
        extras.add(OTel.attributeInt('duffel.slice.count', res.sliceCount!));
      }
      if (res.offerCount != null) {
        extras.add(OTel.attributeInt('duffel.offer.count', res.offerCount!));
      }
      if (res.totalAmountCents != null) {
        extras.add(OTel.attributeInt(
          'duffel.total_amount.cents',
          res.totalAmountCents!,
        ));
      }
      if (res.totalCurrency != null) {
        extras.add(OTel.attributeString(
          'duffel.total.currency',
          res.totalCurrency!,
        ));
      }
      if (res.airline != null) {
        extras.add(OTel.attributeString('duffel.airline', res.airline!));
      }
      if (res.ancillaryKind != null) {
        extras.add(OTel.attributeString(
          'duffel.ancillary.kind',
          res.ancillaryKind!,
        ));
      }
      if (res.ancillaryAmountCents != null) {
        extras.add(OTel.attributeInt(
          'duffel.ancillary.amount_cents',
          res.ancillaryAmountCents!,
        ));
      }
      if (res.paymentMethod != null) {
        extras.add(OTel.attributeString(
          'duffel.payment.method',
          res.paymentMethod!,
        ));
      }
      if (res.orderStatus != null) {
        extras.add(OTel.attributeString(
          'duffel.order.status',
          res.orderStatus!,
        ));
        if (res.orderStatus == 'failed' || res.orderStatus == 'cancelled') {
          span.setStatus(
            SpanStatusCode.Error,
            'Duffel order ${res.orderStatus}',
          );
        }
      }
      if (res.paymentStatus != null) {
        extras.add(OTel.attributeString(
          'duffel.payment.status',
          res.paymentStatus!,
        ));
        if (res.paymentStatus == 'failed') {
          span.setStatus(SpanStatusCode.Error, 'Duffel payment failed');
        }
      }
      if (res.changeRequestId != null) {
        extras.add(OTel.attributeString(
          'duffel.change_request.id',
          res.changeRequestId!,
        ));
      }
      if (res.changeOfferCount != null) {
        extras.add(OTel.attributeInt(
          'duffel.change.offer_count',
          res.changeOfferCount!,
        ));
      }
      if (res.refundAmountCents != null) {
        extras.add(OTel.attributeInt(
          'duffel.refund.amount_cents',
          res.refundAmountCents!,
        ));
      }
      if (res.errorType != null) {
        extras.add(OTel.attributeString(
          'duffel.error.type',
          res.errorType!,
        ));
        span.setStatus(SpanStatusCode.Error, 'Duffel ${res.errorType}');
      }
      if (res.errorTitle != null) {
        extras.add(OTel.attributeString(
          'duffel.error.title',
          res.errorTitle!,
        ));
      }
      if (res.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          res.statusCode!,
        ));
        if (res.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Duffel HTTP ${res.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
