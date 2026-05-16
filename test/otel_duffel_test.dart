// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_duffel/otel_duffel.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(serviceName: 'otel_duffel-test');
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('orders.create records airline + payment + booking ref', () async {
    await tracedDuffel<String>(
      operation: 'orders.create',
      invoke: () async => const DuffelCallResult(
        value: 'ok',
        result: DuffelResult(
          environment: 'live',
          offerId: 'off_1',
          orderId: 'ord_1',
          bookingReference: 'ABCDEF',
          origin: 'LHR',
          destination: 'JFK',
          passengerCount: 1,
          cabinClass: 'economy',
          totalAmountCents: 28500,
          totalCurrency: 'USD',
          airline: 'BA',
          paymentMethod: 'balance',
          orderStatus: 'paid',
          paymentStatus: 'succeeded',
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('duffel orders.create')!);
    expect(a['duffel.airline'], 'BA');
    expect(a['duffel.order.booking_reference'], 'ABCDEF');
    expect(a['duffel.payment.status'], 'succeeded');
  });

  test('failed payment sets span error', () async {
    await tracedDuffel<String>(
      operation: 'payments.create',
      invoke: () async => const DuffelCallResult(
        value: 'ok',
        result: DuffelResult(paymentStatus: 'failed'),
      ),
    );
    expect(
      spans.findSpanByName('duffel payments.create')!.status,
      SpanStatusCode.Error,
    );
  });

  test('airline_error type sets span error', () async {
    await tracedDuffel<String>(
      operation: 'orders.create',
      invoke: () async => const DuffelCallResult(
        value: 'ok',
        result: DuffelResult(
          errorType: 'airline_error',
          errorTitle: 'Fare not available',
        ),
      ),
    );
    expect(
      spans.findSpanByName('duffel orders.create')!.status,
      SpanStatusCode.Error,
    );
  });

  test('suppression skips spans', () async {
    await runWithoutDuffelInstrumentationAsync(() async {
      await tracedDuffel<String>(
        operation: 'airlines.list',
        invoke: () async => const DuffelCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('duffel '), isEmpty);
  });
}
