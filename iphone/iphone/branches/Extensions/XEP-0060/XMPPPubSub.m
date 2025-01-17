//
//  XMPPPubSub.m
//
//  Created by Duncan Robertson [duncan@whomwah.com]
//

#import "XMPPPubSub.h"
#import "XMPP.h"

#define NS_PUBSUB          @"http://jabber.org/protocol/pubsub"
#define NS_PUBSUB_EVENT    @"http://jabber.org/protocol/pubsub#event"
#define NS_PUBSUB_CONFIG   @"http://jabber.org/protocol/pubsub#node_config"
#define NS_PUBSUB_OWNER    @"http://jabber.org/protocol/pubsub#owner"
#define NS_DISCO_ITEMS     @"http://jabber.org/protocol/disco#items"

#define INTEGRATE_WITH_CAPABILITIES 1

#if INTEGRATE_WITH_CAPABILITIES
#import "XMPPCapabilities.h"
#endif

@implementation XMPPPubSub;

@synthesize pubsubService;

- (id)initWithStream:(XMPPStream *)stream
{
	if ((self = [super initWithStream:stream]))
	{
#if INTEGRATE_WITH_CAPABILITIES
		[xmppStream autoAddDelegate:self toModulesOfClass:[XMPPCapabilities class]];
#endif
	}
	return self;
}

- (void)dealloc
{

  
#if INTEGRATE_WITH_CAPABILITIES
	[xmppStream removeAutoDelegate:self fromModulesOfClass:[XMPPCapabilities class]];
#endif
	

}

#pragma mark -
#pragma mark xmppStream Delegate overides
#pragma mark -

/*
 * Delegate method to intercept incoming IQ stanzas
 *
*/
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{   
  // is this a result stanza
  if ([iq isResultIQ])
  {
    
    NSXMLElement *pubsub = [iq elementForName:@"pubsub" xmlns:NS_PUBSUB];
    if (pubsub) 
    {
      // <iq from="pubsub.xmpp.local" to="tv@xmpp.local/radioaunty" id="00CA1177D408:subscribenode" type="result">
      //  <pubsub xmlns="http://jabber.org/protocol/pubsub">
      //   <subscription jid="tv@xmpp.local" subscription="subscribed" subid="4F7B6EEBAD61"></subscription>
      //  </pubsub>
      // </iq>
      
      NSXMLElement *subscription = [pubsub elementForName:@"subscription"];
      if (subscription && 
          [[[subscription attributeForName:@"subscription"] stringValue] isEqualToString:@"subscribed"])
      {        
   
        [multicastDelegate xmppPubSub:self didSubscribe:iq];
        
        return YES;
      }
      
    }
    
    [multicastDelegate xmppPubSub:self didReceiveResult:iq];     
    
    return YES;
    
  } else if ([iq isErrorIQ]) {
    
    [multicastDelegate xmppPubSub:self didReceiveError:iq]; 

    return YES;    
  }
  
  return NO;
}


/*
 * Delegate method to intercept incoming Message stanzas
 *
 */
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
  // <message from='pubsub.foo.co.uk' to='admin@foo.co.uk'>
  //  <event xmlns='http://jabber.org/protocol/pubsub#event'>
  //   <items node='/pubsub.foo'>
  //    <item id='5036AA52A152B'>
  //     <text id='724427814855'>Huw Stephens sits in for Greg James and David Garrido takes a look at the sporting week</text>
  //    </item>
  //   </items>
  //  </event>
  // </message>
	
  NSXMLElement *event = [message elementForName:@"event" xmlns:NS_PUBSUB_EVENT];
  
  if (event) {
    [multicastDelegate xmppPubSub:self didReceiveMessage:message];
  }
}


#pragma mark -
#pragma mark subscription methods
#pragma mark -

- (NSString*)subscribeToNode:(NSString*)node withOptions:(NSDictionary*)options
{
  // <iq type='set' from='francisco@denmark.lit/barracks' to='pubsub.shakespeare.lit' id='sub1'>
  //  <pubsub xmlns='http://jabber.org/protocol/pubsub'>
  //   <subscribe node='princely_musings' jid='francisco@denmark.lit'/>
  //  </pubsub>
  // </iq>
  
  NSString *sid = [NSString stringWithFormat:@"%@:subscribe_node", self.xmppStream.generateUUID];
  
  XMPPIQ *iq = [XMPPIQ iqWithType:@"set" to:self.pubsubService elementID:sid];
  NSXMLElement *ps = [NSXMLElement elementWithName:@"pubsub" xmlns:NS_PUBSUB];
  NSXMLElement *subscribe = [NSXMLElement elementWithName:@"subscribe"];
  [subscribe addAttributeWithName:@"node" stringValue:node];
  [subscribe addAttributeWithName:@"jid" stringValue:[self.xmppStream.myJID full]];
  
  [ps addChild:subscribe];
  [iq addChild:ps];
  
  [self.xmppStream sendElement:iq];
  
  return sid;
}


- (NSString*)unsubscribeFromNode:(NSString*)node
{
  // <iq type='set' from='francisco@denmark.lit/barracks' to='pubsub.shakespeare.lit' id='unsub1'>
  //  <pubsub xmlns='http://jabber.org/protocol/pubsub'>
  //   <unsubscribe node='princely_musings' jid='francisco@denmark.lit'/>
  //  </pubsub>
  // </iq>
  
  NSString *sid = [NSString stringWithFormat:@"%@:unsubscribe_node", self.xmppStream.generateUUID]; 
  
  XMPPIQ *iq = [XMPPIQ iqWithType:@"set" to:self.pubsubService elementID:sid];
  NSXMLElement *ps = [NSXMLElement elementWithName:@"pubsub" xmlns:NS_PUBSUB];
  NSXMLElement *subscribe = [NSXMLElement elementWithName:@"unsubscribe"];
  [subscribe addAttributeWithName:@"node" stringValue:node];
  [subscribe addAttributeWithName:@"jid" stringValue:[self.xmppStream.myJID full]];
  
  // join them all together
  [ps addChild:subscribe];
  [iq addChild:ps];
  
  [self.xmppStream sendElement:iq];
  
  return sid;
}


#pragma mark -
#pragma mark Node admin
#pragma mark -

- (NSString*)createNode:(NSString*)node withOptions:(NSDictionary*)options
{
  // <iq type='set' from='hamlet@denmark.lit/elsinore' to='pubsub.shakespeare.lit' id='create1'>
  //  <pubsub xmlns='http://jabber.org/protocol/pubsub'>
  //   <create node='princely_musings'/>
  //   <configure>
  //    <x xmlns='jabber:x:data' type='submit'>
  //     <field var='FORM_TYPE' type='hidden'>
  //      <value>http://jabber.org/protocol/pubsub#node_config</value>
  //     </field>
  //     <field var='pubsub#title'><value>Princely Musings (Atom)</value></field>
  //     <field var='pubsub#deliver_notifications'><value>1</value></field>
  //     <field var='pubsub#deliver_payloads'><value>1</value></field>
  //     <field var='pubsub#persist_items'><value>1</value></field>
  //     <field var='pubsub#max_items'><value>10</value></field>
  //     ...
  //    </x>
  //   </configure>
  //  </pubsub>
  // </iq>
  
  NSString *sid = [NSString stringWithFormat:@"%@:create_node", self.xmppStream.generateUUID];
  
  XMPPIQ *iq = [XMPPIQ iqWithType:@"set" to:self.pubsubService elementID:sid];
  NSXMLElement *ps = [NSXMLElement elementWithName:@"pubsub" xmlns:NS_PUBSUB];
  NSXMLElement *create = [NSXMLElement elementWithName:@"create"];
  [create addAttributeWithName:@"node" stringValue:node];
  
  if (options != nil && [options count] > 0) {
  
    NSXMLElement *config = [NSXMLElement elementWithName:@"configure"];
    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"jabber:x:data"];
    [x addAttributeWithName:@"type" stringValue:@"submit"];
    
    NSXMLElement *field = [NSXMLElement elementWithName:@"field"];
    [field addAttributeWithName:@"var" stringValue:@"FORM_TYPE"];
    [field addAttributeWithName:@"type" stringValue:@"hidden"];
    NSXMLElement *value = [NSXMLElement elementWithName:@"value"];
    [value setStringValue:NS_PUBSUB_CONFIG];
    [field addChild:value];
    [x addChild:field];
    
    NSXMLElement *f;
    NSXMLElement *v;
    for (NSString *item in options) {
      f = [NSXMLElement elementWithName:@"field"];
      [f addAttributeWithName:@"var" stringValue:[NSString stringWithFormat:@"pubsub#%@", [options valueForKey:item]]];
      v = [NSXMLElement elementWithName:@"value"];
      [v setStringValue:item];
      [f addChild:v];
      [x addChild:f];
    }
    
    [config addChild:x];
    [ps addChild:config];
    
  }
    
  [ps addChild:create];
  [iq addChild:ps];
  
  [self.xmppStream sendElement:iq];
  
  return sid;
}

/**
 * This method currently does not support redirection
**/
- (NSString*)deleteNode:(NSString*)node
{
  // <iq type='set' from='hamlet@denmark.lit/elsinore' to='pubsub.shakespeare.lit' id='delete1'>
  //  <pubsub xmlns='http://jabber.org/protocol/pubsub#owner'>
  //   <delete node='princely_musings'>
  //    <redirect uri='xmpp:hamlet@denmark.lit?;node=blog'/>
  //   </delete>
  //  </pubsub>
  // </iq>
  
  NSString *sid = [NSString stringWithFormat:@"%@:delete_node", self.xmppStream.generateUUID];
  XMPPIQ *iq = [XMPPIQ iqWithType:@"set" to:self.pubsubService elementID:sid];
  NSXMLElement *ps = [NSXMLElement elementWithName:@"pubsub" xmlns:NS_PUBSUB_OWNER];
  
  NSXMLElement *delete = [NSXMLElement elementWithName:@"delete"];
  [delete addAttributeWithName:@"node" stringValue:node];
  
  [ps addChild:delete];
  [iq addChild:ps];

  [self.xmppStream sendElement:iq];
  
  return sid;
}


- (NSString*)allItemsForNode:(NSString*)node
{
  // <iq type='get' from='francisco@denmark.lit/barracks' to='pubsub.shakespeare.lit' id='nodes2'>
  //  <query xmlns='http://jabber.org/protocol/disco#items' node='blogs'/>
  // </iq>
  
  NSString *sid = [NSString stringWithFormat:@"%@:items_for_node", self.xmppStream.generateUUID];
  XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:self.pubsubService elementID:sid];
  NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:NS_DISCO_ITEMS];

  if (node != nil) {
    [query addAttributeWithName:@"node" stringValue:node];  
  }
  
  [iq addChild:query];
  
  [self.xmppStream sendElement:iq];
  
  return sid;
}


- (NSString*)configureNode:(NSString*)node
{
  // <iq type='get' from='hamlet@denmark.lit/elsinore' to='pubsub.shakespeare.lit' id='config1'>
  //  <pubsub xmlns='http://jabber.org/protocol/pubsub#owner'>
  //   <configure node='princely_musings'/>
  //  </pubsub>
  // </iq>
  
  NSString *sid = [NSString stringWithFormat:@"%@:configure_node", self.xmppStream.generateUUID];
  XMPPIQ *iq = [XMPPIQ iqWithType:@"get" to:self.pubsubService elementID:sid];
  NSXMLElement *ps = [NSXMLElement elementWithName:@"pubsub" xmlns:NS_PUBSUB_OWNER];
  
  NSXMLElement *conf  = [NSXMLElement elementWithName:@"configure"];
  [conf addAttributeWithName:@"node" stringValue:node];
  
  [ps addChild:conf];
  [iq addChild:ps];
  
  [self.xmppStream sendElement:iq];
  
  return sid;
}
  

#if INTEGRATE_WITH_CAPABILITIES
/**
 * If an XMPPCapabilites instance is used we want to advertise our support for pubsub support.
 **/
- (void)xmppCapabilities:(XMPPCapabilities *)sender willSendMyCapabilities:(NSXMLElement *)query
{
	// <query xmlns="http://jabber.org/protocol/disco#info">
	//   ...
  //   <feature var='http://jabber.org/protocol/pubsub'/>
	//   ...
	// </query>
  
  NSXMLElement *identity = [NSXMLElement elementWithName:@"identity"];
  [identity addAttributeWithName:@"category" stringValue:@"pubsub"];
  [identity addAttributeWithName:@"type" stringValue:@"service"];
  [query addChild:identity];
  
	NSXMLElement *feature = [NSXMLElement elementWithName:@"feature"];
	[feature addAttributeWithName:@"var" stringValue:NS_PUBSUB];
	
	[query addChild:feature];
}
#endif

@end
