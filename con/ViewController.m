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
    label.text = ShowWeather[indexPath.row];
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
        //Вывод на экран ошибки соединения
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
    // Обработка полученной информации
    
    ShowWeather = [[NSMutableArray alloc] init]; //создание таблицы для вывода
    
    
    NSError *e = nil;
    NSDictionary *JSONWeather = [NSJSONSerialization JSONObjectWithData: _responseData options: NSJSONReadingMutableContainers error: &e]; //преобразование полученной информации через NSJSONSerialization
   
    //NSLog(@"%@",JSONWeather); //вывод полученных данных в консоль
    
    NSDictionary *Clouds = [self GetSubDict:JSONWeather KeyToFind:@"clouds"]; //получение подсловаря с данными по облачности
    
    [ShowWeather addObject:[self GetStringFromDict:Clouds KeyToFind:@"all" Description:@"Clouds: " Units:@" \%"]]; // добавление данных по облачности
    NSLog(@"Clouds added"); //вывод в консоль об успешном добавлении
    
    NSDictionary *Main = [self GetSubDict:JSONWeather KeyToFind:@"main"];// получение подсловаря с основным данным
     NSLog(@"Maine added");
    
    [ShowWeather addObject:[self GetStringFromDict:Main KeyToFind:@"humidity" Description:@"Humidity: " Units:@" \%"]];
    [ShowWeather addObject:[self GetStringFromDict:Main KeyToFind:@"pressure" Description:@"Pressure: " Units:@" mbar"]];
    [ShowWeather addObject:[self GetStringFromDict:Main KeyToFind:@"temp" Description:@"Temperature: " Units:@" С"]];
    [ShowWeather addObject:[self GetStringFromDict:Main KeyToFind:@"temp_max" Description:@"Max Temperature: " Units:@" С"]];
    [ShowWeather addObject:[self GetStringFromDict:Main KeyToFind:@"temp_min" Description:@"Min Temperature: " Units:@" C"]];
    
    
    [ShowWeather insertObject:[self GetStringFromDict:JSONWeather KeyToFind:@"name" Description:@"City: " Units:@""] atIndex:0];
     NSLog(@"City added");//вывод в консоль об успешном добавлении
    
    NSDictionary *Sys = [self GetSubDict:JSONWeather KeyToFind:@"sys"];//получение подсловаря с системными данными
     NSLog(@"Sys added");//вывод в консоль об успешном добавлении
    
    [ShowWeather insertObject:[self GetStringFromDict:Sys KeyToFind:@"country" Description:@"Country: " Units:@""] atIndex:0];
    [ShowWeather addObject:[self GetStringFromDict:Sys KeyToFind:@"sunrise" Description:@"Sunrise: "Units:@""]];
    [ShowWeather addObject:[self GetStringFromDict:Sys KeyToFind:@"sunset" Description:@"Sunset: "Units:@""]];
    
    
    if (JSONWeather[@"weather"]!=Nil)//проверка на существование данных по погоде
    {
        NSDictionary *Weather = JSONWeather[@"weather"][0];//получение подсловаря с данными по погоде из таблицы, содержащей один элемент
        NSLog(@"Weather added");//вывод в консоль об успешном добавлении
        [ShowWeather addObject:[self GetStringFromDict:Weather KeyToFind:@"main" Description:@"Weather: " Units:@""]];
        [ShowWeather addObject:[self GetStringFromDict:Weather KeyToFind:@"description" Description:@"Deteil: "Units:@""]];
    }


    
     NSDictionary *Wind = [self GetSubDict:JSONWeather KeyToFind:@"wind"];//получение подсловаря с данными по ветру
     NSLog(@"wind added");//вывод в консоль об успешном добавлении
    
    [ShowWeather addObject:[self GetStringFromDict:Wind KeyToFind:@"deg" Description:@"Wind: " Units:@" deg"]];
    [ShowWeather addObject:[self GetStringFromDict:Wind KeyToFind:@"speed" Description:@"Wind speed: " Units:@" mph"]];
    
    NSLog(@"%@", ShowWeather);//вывод в консоль полученных данных
    [_tabelView reloadData]; //перезагрзка таблицы выводит полученные данные в таблицу
    self.tabelView.hidden = NO; //Отображение таблицы на экране
    self.Lable1.hidden=YES; //Лейбл с данными о состоянии загрузки прячется
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //  error
    NSLog(@"Error");
    _Lable1.text =@"Error"; //вывод ошибки в случае прерывания загрузки данных
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSDictionary *) GetSubDict:(id)SuperDict KeyToFind: (NSString *)SearchKey //метод для выделения подсловаря, если подсловарь не найден, возвращает ноль
{
    if (SuperDict[SearchKey]!=Nil) //проверка на наличие подсловаря
    {
        return SuperDict[SearchKey];
        
    }else{return Nil;}
}

-(NSString *)GetStringFromDict:(id)Dict KeyToFind: (NSString *)SearchKey Description: (NSString *) WhatIsIt Units: (NSString *) Unit //метод для формирования строки с даннми из словая, если данные не найдены, возвращает ноль
{
    if (Dict[SearchKey]!=Nil)
    {
        if ([WhatIsIt isEqual:@"Temperature: "]|[WhatIsIt isEqual:@"Max Temperature: "]|[WhatIsIt isEqual:@"Min Temperature: "]) //проверка являются ли обрабатываемые данные температурой, которую нужно перевести в градусы Цельсия
        {
            return [[WhatIsIt stringByAppendingString:[NSString stringWithFormat:@"%@", [self TemperatureInCelsius:Dict[SearchKey]]]] stringByAppendingString:Unit]; //использование специального метода для конвертации гардусов
        }
        if ([WhatIsIt isEqual:@"Sunrise: "]|[WhatIsIt isEqual:@"Sunset: "]) //Проверка являются ли данные датой заката или восхода, которую нужно отформатировать
        {
            return [[WhatIsIt stringByAppendingString:[NSString stringWithFormat:@"%@", [self timeFormatted:Dict[SearchKey]]]]stringByAppendingString:Unit]; //использование специального метода для форматирования даты
        }
        return [[WhatIsIt stringByAppendingString:[NSString stringWithFormat:@"%@", Dict[SearchKey]]]stringByAppendingString:Unit];
        
    }else{return Nil;}
}
- (NSString *) TemperatureInCelsius:(NSString *)TempInKelvin{
   //Перевод Кельвинов в Цельсии
    
    long Temper = [TempInKelvin floatValue]; //перевод полученной строки в число
    NSString *StrTemp = [NSString stringWithFormat:@"%1.2ld", Temper-273]; //перевод значения в Цельсии
    
    return StrTemp; //возврат строки, содержащей температуру в нужных единицах

}

- (NSString *)timeFormatted:(NSString *)totalSeconds //функция форматирования даты

{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; //инициализация форматтера
    [dateFormatter setDateStyle:NSDateFormatterNoStyle]; //установка формата даты: нет стиля - дата не отображается
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle]; // установка формата времени
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[totalSeconds longLongValue]]; //перевод полученного количества секунд в число и перевод к стандартной дате
    
    return [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:date]]; // возврат строки, содержащей время в нужном формате
}

@end