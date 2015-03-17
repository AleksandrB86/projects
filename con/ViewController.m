//
//  ViewController.m
//  con
//
//  Created by Aleksandr Budnik on 11.03.15.
//  Copyright (c) 2015 Aleksandr Budnik. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@interface ViewController () <NSURLConnectionDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *ShowWeather;
    
}

@property (weak, nonatomic) IBOutlet UITableView *tabelView;
@property (weak, nonatomic) IBOutlet UILabel *Lable1;
@property (strong, nonatomic) NSMutableData * responseData;
@end


@implementation ViewController



- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"TableCell"];
    UILabel* label = (UILabel*)[cell viewWithTag:5];
    
    NSLog(@"%@",ShowWeather[indexPath.row]);
    label.text = ShowWeather[indexPath.row];//[NSString stringWithFormat:@"%ld",(long)indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return ShowWeather.count;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://api.openweathermap.org/data/2.5/weather?q=Kharkov,ua"]];
    //Создать соединение и послать запрос
    NSURLConnection *connectin = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connectin)
    { _Lable1.text = @"Connecting...";
        NSLog(@"%s", "Connection Work");
    }else{
        _Lable1.text=@"Error!";
    }
}



- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //Инициализиация переменной
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Добавить новые данные в переменную
    [ _responseData appendData:data];
    
}
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Возвращает nil чтобы показать что нет необходимости кэшировать ответ
    return nil;
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Обработка переменной
    NSString *text;
    
    ShowWeather = [[NSMutableArray alloc] init];
    
    text=[[NSString alloc] initWithData:_responseData encoding: NSUTF8StringEncoding];
    NSArray *SectionArray = [text componentsSeparatedByString:@"},"];
    NSLog(@"%@",SectionArray);
    
    NSArray *SysArray = [ SectionArray[1] componentsSeparatedByString:@","];
    NSLog(@"%s", "Work with array Sys");

    
    [ShowWeather addObject:[self GetWeatherFormString:SysArray[3] Caption:@"Country: \"" IndexForStart:11]];

    //[ShowWeather addObject:[self timeFormatted:(int)[self GetWeatherFormString:SysArray[2] Caption:@"Sunrise: " IndexForStart:10]]];
    
    //[ShowWeather addObject:[self timeFormatted:(int)[self GetWeatherFormString:SysArray[3] Caption:@"Sunset: " IndexForStart:9]]];
    
    NSArray *WeatherArray = [SectionArray[2] componentsSeparatedByString:@","];
    NSLog(@"%s", "Work with array Weather");
    
    [ShowWeather addObject:[self GetWeatherFormString:WeatherArray[1] Caption:@"Weather: \"" IndexForStart:8]];
     NSLog(@"%s", "Worked with array Weather:maine");

    [ShowWeather addObject:[self GetWeatherFormString:WeatherArray[2] Caption:@"Description: \"" IndexForStart:15]];
     NSLog(@"%s", "Worked with array Weather:Description");

    
    [ShowWeather addObject:[self GetWeatherFormString:WeatherArray[5] Caption:@"Temperature: " IndexForStart:15]];
     NSLog(@"%s", "Worked with array Weather:Temp");
    
    [ShowWeather addObject:[self GetWeatherFormString:WeatherArray[8] Caption:@"Min Temperature: " IndexForStart:11]];
     NSLog(@"%s", "Worked with array Weather:Temp min");
   
    
    [ShowWeather addObject:[self GetWeatherFormString:WeatherArray[9] Caption:@"Max Temperature: " IndexForStart:11]];
     NSLog(@"%s", "Worked with array Weather:temp_max");
    
    [ShowWeather addObject:[self GetWeatherFormString:WeatherArray[6] Caption:@"Preasure: " IndexForStart:13]];
    NSLog(@"%s", "Worked with array Weather:preasure");
    
    [ShowWeather addObject:[self GetWeatherFormString:WeatherArray[7] Caption:@"Humidity: " IndexForStart:11]];
    NSLog(@"%s", "Worked with array Weather:humidity");
    
    NSArray *WindArray = [SectionArray[3] componentsSeparatedByString:@","];
    NSLog(@"%s", "Work with array Wind");
   
   [ShowWeather addObject:[self GetWeatherFormString:WindArray[0] Caption:@"Wind Speed: " IndexForStart:16]];

   // NSLog(@"%s", "Work with array Clouds");
    //[ShowWeather addObject:[self GetWeatherFormString:SectionArray[4] Caption:@"Clouds: " IndexForStart:11]];
    
   
   NSArray *DtArray = [SectionArray[5] componentsSeparatedByString:@","];
       NSLog(@"%s", "Work with array DT");
    [ShowWeather insertObject:[self GetWeatherFormString:DtArray[2] Caption:@"City: " IndexForStart:7] atIndex:1];
    
    
    //NSLog(@"%@",text);
     NSLog(@"%@ %ld",ShowWeather, ShowWeather.count);
    [_tabelView reloadData];
    self.tabelView.hidden = NO;
    self.Lable1.hidden=YES;
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //  error
    NSLog(@"Error");
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *) GetWeatherFormString: (NSString *)StringWithWeather Caption: (NSString *)WhatIsIt IndexForStart: (int)StartIndex {
    
    NSRange ResulStringRange = NSMakeRange(StartIndex,  StringWithWeather.length-StartIndex);
    //if ([WhatIsIt isEqual:@"Temperature: "]|[WhatIsIt isEqual:@"Min Temperature: "]|[WhatIsIt isEqual:@"Max Temperature: "])
    //{return [WhatIsIt stringByAppendingString:[self TemperatureInCelsius:(long)[StringWithWeather substringWithRange:ResulStringRange]]];}
    
    return [WhatIsIt stringByAppendingString:[StringWithWeather substringWithRange:ResulStringRange]];
}

- (long) TemperatureInCelsius:(long)TempInKelvin{
    
    return TempInKelvin-273;
}

- (NSString *)timeFormatted:(int)totalSeconds

{
    
    int seconds = totalSeconds % 60;
    
    int minutes = (totalSeconds / 60) % 60;
    
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
    
}

@end