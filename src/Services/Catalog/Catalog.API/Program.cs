var builder = WebApplication.CreateBuilder(args);

builder.Services.AddCarter();
builder.Services.AddMediatR(config =>
{
    config.RegisterServicesFromAssembly(typeof(Program).Assembly);
});
builder.Services.AddMarten(options =>
{
    options.Connection(builder.Configuration.GetConnectionString("MartenConnection")!);

}).UseLightweightSessions();

//Add Services to the container.

var app = builder.Build();

// Configure the HTTP request pipeline.
app.MapCarter();
app.Run();
