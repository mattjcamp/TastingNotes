//
//  NoteView.m
//  TastingNotes
//
//  Created by Matthew Campbell on 9/18/12.
//
//

#import "NoteAdder.h"
#import "ContentTableViewCell.h"
#import "ContentFullScreen.h"

@implementation NoteAdder
Note *_note;

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *l = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 100, 30)];
    l.backgroundColor = [UIColor darkGrayColor];
    l.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    l.textColor = [UIColor lightGrayColor];
    l.textAlignment = NSTextAlignmentCenter;
    Section *s = [self.note.notebook.listOfSections objectAtIndex:section];
    l.text = s.name;
    
    return l;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.note.notebook.listOfSections count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    Section *s = [self.note.notebook.listOfSections objectAtIndex:section];
    return s.name;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	Section *s = [self.note.notebook.listOfSections objectAtIndex:section];
    if(s ==[self.note.notebook.listOfSections lastObject])
        return [s.listOfControls count] + 1;
    else
        return [s.listOfControls count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Section *s = [self.note.notebook.listOfSections objectAtIndex:indexPath.section];
    if(indexPath.row >= s.listOfControls.count)
        return 200;
    else{
        Control *control = [s.listOfControls objectAtIndex:indexPath.row];
        
        if([control.type isEqualToString:@"MultiText"])
            return 144;
        if([control.type isEqualToString:@"100PointScale"])
            return 70;
        if([control.type isEqualToString:@"Picture"])
            return 144;
        if([control.type isEqualToString:@"Date"])
            return 247;
        
        return 65;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    Section *s = [self.note.notebook.listOfSections objectAtIndex:indexPath.section];
    if(indexPath.row >= s.listOfControls.count){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Spacer"];
        return cell;
    }
    else{
        Control *control = [s.listOfControls objectAtIndex:indexPath.row];
        Content *content = [self.note contentInThisControl:control];
        if(!content){
            [self.note addContentToThisControl:control];
            content = [self.note contentInThisControl:control];
        }
        
        ContentTableViewCell *customCell = (ContentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:control.type];
        
        if(customCell){
            [customCell setContent:content];
            [customCell setNeedsDisplay];
            return customCell;
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tv scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [[self.tapToAddButton layer] setCornerRadius:8.0f];
    [[self.tapToAddButton layer] setMasksToBounds:YES];
    [self.view bringSubviewToFront:self.vc];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tv reloadData];
}

-(void)setNote:(Note *)note{
    _note = note;
    self.title = self.note.titleText;
}

- (void)viewDidUnload {
    [self setTv:nil];
    [self setAddButton:nil];
    [self setDoneButton:nil];
    [super viewDidUnload];
}

- (IBAction)editButtonAction:(id)sender {
    [UIView animateWithDuration:0.5 animations:^{
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
                               forView:self.view cache:YES];
        [self.view bringSubviewToFront:self.tv];
    }];
    self.navigationItem.rightBarButtonItem = self.doneButton;
}

- (IBAction)doneButtonAction:(id)sender {
    [UIView animateWithDuration:1.0 animations:^{
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown
                               forView:self.view cache:YES];
        self.note = nil;
        [self.view bringSubviewToFront:self.vc];
        self.toolbar.hidden = YES;
    }];
    self.navigationItem.rightBarButtonItem = nil;
}

- (IBAction)addButtonAction:(id)sender {
    [UIView animateWithDuration:1.0 animations:^{
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp
                               forView:self.view cache:YES];
        [[[AppContent sharedContent] activeNotebook] addNoteToThisNotebook];
        self.note = [[[[AppContent sharedContent] activeNotebook] listOfNotes] lastObject];
        self.toolbar.hidden = NO;
        [self.view bringSubviewToFront:self.tv];
        [self.view bringSubviewToFront:self.toolbar];
    }];
    
    [self.tv reloadData];
}

- (IBAction)socialButtonAction:(id)sender {
    UIActivityViewController *avc;
    if(self.note.thumbnail)
        avc = [[UIActivityViewController alloc] initWithActivityItems:@[self.note.thumbnail, self.note.socialString] applicationActivities:nil];
    else
        avc = [[UIActivityViewController alloc] initWithActivityItems:@[self.note.socialString] applicationActivities:nil];
    avc.excludedActivityTypes = @[UIActivityTypeMessage, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];
    [self presentViewController:avc animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:@"ToImageEditor"]) {
        NSIndexPath *indexPath = [self.tv indexPathForSelectedRow];
        Section *s = [self.note.notebook.listOfSections objectAtIndex:indexPath.section];
        Control *control = [s.listOfControls objectAtIndex:indexPath.row];
        Content *content = [self.note contentInThisControl:control];
        
        ContentFullScreen *dvc = (ContentFullScreen *)[segue destinationViewController];
        [dvc setContent:content];
        [dvc addUpdateBlock:^{
            ContentTableViewCell *customCell =(ContentTableViewCell *) [self.tv cellForRowAtIndexPath:indexPath];
            [customCell setNeedsDisplay];
        }];
    }
    if ([[segue identifier] isEqualToString:@"ToListEditor"]) {
        NSIndexPath *indexPath = [self.tv indexPathForSelectedRow];
        Section *s = [self.note.notebook.listOfSections objectAtIndex:indexPath.section];
        Control *control = [s.listOfControls objectAtIndex:indexPath.row];
        Content *content = [self.note contentInThisControl:control];
        
        ContentFullScreen *dvc = (ContentFullScreen *)[segue destinationViewController];
        [dvc setContent:content];
        [dvc addUpdateBlock:^{
            ContentTableViewCell *customCell =(ContentTableViewCell *) [self.tv cellForRowAtIndexPath:indexPath];
            [customCell setNeedsDisplay];
        }];
    }
}

-(void)lockEditingWhileDoingDatabaseRestore{
    self.note = nil;
    [self.view bringSubviewToFront:self.vc];
    self.toolbar.hidden = YES;
    self.navigationItem.rightBarButtonItem = nil;
    self.tapToAddButton.hidden = YES;
}

-(void)unlockEditingAfterDoingDatabaseRestore{    
    [UIView animateWithDuration:1.0 animations:^{
        self.tv.alpha = 0.0;
    }];
    self.toolbar.hidden = YES;
    self.tapToAddButton.hidden = NO;
    [self.view bringSubviewToFront:self.vc];
    [self.view bringSubviewToFront:self.tapToAddButton];
    [UIView animateWithDuration:1.0 animations:^{
        self.tv.alpha = 1.0;
    }];
}

@end