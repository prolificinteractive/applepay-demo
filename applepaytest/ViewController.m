//
//  ViewController.m
//  applepaytest
//
//  Created by Max Mamis on 9/11/14.
//  Copyright (c) 2014 Prolific. All rights reserved.
//

#import "ViewController.h"
#import "Passkit/Passkit.h"

static NSString * const kShippingMethodCarrierPidgeon = @"Carrier Pidgeon";
static NSString * const kShippingMethodUberRush       = @"Uber Rush";
static NSString * const kShippingMethodSentientDrone  = @"Sentient Drone";

@interface ViewController () <PKPaymentAuthorizationViewControllerDelegate>

@end

@implementation ViewController

- (IBAction)buyWithApplePay:(id)sender
{
    PKPaymentRequest *request = [PKPaymentRequest new];
    
    // The last item is prefixed with "Pay to x", in this case it will be "Pay to total"
    PKPaymentSummaryItem *lineItem1 = [self paymentSummaryItemWithLabel:@"Dog Hammock" amount:29.99f];
    PKPaymentSummaryItem *lineItem2 = [self paymentSummaryItemWithLabel:@"Cat Bunkbed" amount:39.99f];
    PKPaymentSummaryItem *total = [self paymentSummaryItemWithLabel:@"Total" amount:69.98f];
    [request setPaymentSummaryItems:@[lineItem1, lineItem2, total]];
    
    // Identifier is for internal dev use, detail is user visible.
    // Both are strings
    NSArray *shippingMethods = @[
        [self shippingMethodWithIdentifier:kShippingMethodCarrierPidgeon detail:kShippingMethodCarrierPidgeon amount:10.f],
        [self shippingMethodWithIdentifier:kShippingMethodUberRush detail:kShippingMethodUberRush amount:15.f],
        [self shippingMethodWithIdentifier:kShippingMethodSentientDrone detail:kShippingMethodSentientDrone amount:20.f]
    ];
    request.shippingMethods = shippingMethods;

    // Must be configured in Apple Developer Member Center
    // Doesn't seem like the functionality is there yet
    request.merchantIdentifier = @"com.prolificinteractive.give-us-your-money";
    
    // These appear to be the only 3 supported
    // Sorry, Discover Card
    request.supportedNetworks = @[PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa];
    
    // What type of info you need (eg email, phone, address, etc);
    request.requiredBillingAddressFields = PKAddressFieldAll;
    request.requiredShippingAddressFields = PKAddressFieldPostalAddress;
    
    // Which payment processing protocol the vendor supports
    // This value depends on the back end, looks like there are two possibilities
    request.merchantCapabilities = PKMerchantCapability3DS;

    request.countryCode = @"US";
    request.currencyCode = @"USD";
    
    // Let's go!
    PKPaymentAuthorizationViewController *authVC = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
    authVC.delegate = self;
    [self presentViewController:authVC animated:YES completion:nil];
}

#pragma mark - Convenience methods
- (PKPaymentSummaryItem *)paymentSummaryItemWithLabel:(NSString *)label amount:(CGFloat)amount
{
    NSDecimalNumber *decimalAmount = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithFloat:amount] decimalValue]];
    return [PKPaymentSummaryItem summaryItemWithLabel:label amount:decimalAmount];
}

- (PKShippingMethod *)shippingMethodWithIdentifier:(NSString *)idenfifier detail:(NSString *)detail amount:(CGFloat)amount
{
    PKShippingMethod *shippingMethod = [PKShippingMethod new];
    shippingMethod.identifier = idenfifier;
    shippingMethod.detail = @"";
    shippingMethod.amount = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithFloat:amount] decimalValue]];
    shippingMethod.label = detail;
    
    return shippingMethod;
}

#pragma mark - PKPaymentAuthorizationViewControllerDelegate methods

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus))completion
{
    // Can't get this to fire
    // BUT if I could, I would have a PKPayment object, which contains an opaque (to us) payment token
    // I'd probably want to hand this over to my payment processor's SDK at this point
    // It also contains ABRecordRefs for the billing/shipping addresses
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
    // This fires when I successfully complete billing/shipping info
    // Or when I hit Cancel
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                  didSelectShippingAddress:(ABRecordRef)address
                                completion:(void (^)(PKPaymentAuthorizationStatus, NSArray *, NSArray *))completion
{
    // This is where you would update the shipping methods based on the user's address
    // pass an array into the (mandatory) completion block

    // You can also abort payment here if you can't ship to the user's address by changing PKPaymentAuthorizationStatus
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                   didSelectShippingMethod:(PKShippingMethod *)shippingMethod
                                completion:(void (^)(PKPaymentAuthorizationStatus, NSArray *))completion
{
    // This is where you update the line items & total to reflect the user's chosen shipping method
}
@end
